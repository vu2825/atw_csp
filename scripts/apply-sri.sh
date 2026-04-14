#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# apply-sri.sh — Tự động thêm SRI hash vào tất cả file JSP
# Chạy từ thư mục gốc dự án: bash scripts/apply-sri.sh
# ═══════════════════════════════════════════════════════════════

WEBAPP="src/main/webapp"
OLD_HREF='href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"'
NEW_TAG='href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"\n      integrity="sha384-OLBgp1GsljhM2TJ+sbHjaiH9txEUvgdDTAzHv2P24donTt6/529l+9Ua0vFImLlb"\n      crossorigin="anonymous"'

echo "🔍 Tìm các file JSP cần cập nhật..."
FILES=$(grep -rl 'font-awesome/6.5.0/css/all.min.css' "$WEBAPP" --include="*.jsp")

if [ -z "$FILES" ]; then
    echo "✅ Không tìm thấy file nào cần cập nhật."
    exit 0
fi

echo "📄 Các file sẽ được sửa:"
echo "$FILES"
echo ""

for f in $FILES; do
    # Kiểm tra xem đã có integrity chưa
    if grep -q 'integrity=' "$f"; then
        echo "  ⏭️  Bỏ qua (đã có SRI): $f"
        continue
    fi

    # Thay thế href đơn giản thành href + integrity + crossorigin
    # macOS dùng sed -i '' , Linux dùng sed -i
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s|${OLD_HREF}|${NEW_TAG}|g" "$f"
    else
        sed -i "s|${OLD_HREF}|${NEW_TAG}|g" "$f"
    fi

    echo "  ✅ Đã cập nhật: $f"
done

echo ""
echo "🎉 Hoàn tất! Kiểm tra lại bằng lệnh:"
echo "   grep -r 'integrity=' $WEBAPP --include='*.jsp'"
