<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gói Xem Phim - Chọn Kế Hoạch Của Bạn</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f8f9fa; /* Nền sáng nhạt */
            color: #333;
            margin: 0;
            padding: 20px;
            display: flex;
            flex-direction: column;
            align-items: center;
        }
        h1 {
            text-align: center;
            color: #495057;
            margin-bottom: 40px;
        }
        .plans-container {
            display: flex;
            justify-content: center;
            gap: 30px;
            flex-wrap: wrap;
            align-items: stretch; /* Đảm bảo các thẻ có chiều cao bằng nhau */
        }
        .plan-card {
            background-color: #ffffff;
            border: 1px solid #dee2e6;
            border-radius: 8px;
            padding: 30px;
            width: 250px;
            text-align: center;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1); /* Bóng nhẹ cho light theme */
            transition: box-shadow 0.3s ease;
            display: flex; /* Sử dụng flexbox cho thẻ */
            flex-direction: column; /* Hướng dọc */
            flex: 1; /* Các thẻ mở rộng để bằng chiều cao */
            min-width: 250px;
            max-width: 300px;
        }
        .plan-card:hover {
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
        }
        .plan-name {
            font-size: 20px;
            font-weight: bold;
            color: #007bff;
            margin-bottom: 10px;
        }
        .plan-price {
            position: relative;
            display: inline-block;
            margin: 10px 0;
        }
        .original-price {
            text-decoration: line-through;
            color: #6c757d;
            font-size: 18px;
            margin-right: 10px;
        }
        .sale-price {
            font-size: 24px;
            font-weight: bold;
            color: #28a745; /* Màu xanh lá cho giá khuyến mãi */
        }
        .plan-duration {
            color: #6c757d;
            font-size: 14px;
            margin-bottom: 20px;
        }
        .save-badge {
            background-color: #ffc107;
            color: #212529;
            font-size: 12px;
            padding: 4px 8px;
            border-radius: 12px;
            margin-bottom: 10px;
            display: inline-block;
        }
        .feature {
            list-style-type: none;
            padding: 0;
            margin: 20px 0;
            color: #6c757d;
            flex-grow: 1; /* Tính năng mở rộng để lấp đầy không gian, đẩy nút xuống dưới */
            display: flex;
            flex-direction: column;
            justify-content: space-between; /* Phân bố đều nếu cần, nhưng chủ yếu để lấp đầy */
        }
        .feature li {
            padding: 8px 0;
            border-bottom: 1px solid #f8f9fa;
        }
        .feature li:last-child {
            border-bottom: none;
        }
        .buy-button {
            background-color: #007bff;
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            width: 100%;
            margin-top: auto; /* Đẩy nút xuống cuối thẻ */
        }
        .buy-button:hover {
            background-color: #0056b3;
        }
        @media (max-width: 768px) {
            .plans-container {
                flex-direction: column;
                align-items: center;
            }
            .plan-card {
                width: 90%;
                max-width: 300px;
            }
        }
    </style>
</head>
<body>
    <h1>Chọn Gói Xem Phim Của Bạn</h1>
    <p style="text-align: center; color: #6c757d; margin-bottom: 40px;">Khuyến mãi đặc biệt - Tiết kiệm ngay hôm nay với giá giảm!</p>
    <div class="plans-container">
        <!-- Gói 1 Tháng -->
        <div class="plan-card">
            <div class="save-badge">Tiết kiệm 20%</div>
            <div class="plan-name">Gói 1 Tháng</div>
            <div class="plan-price">
                <span class="original-price">$12.99</span>
                <span class="sale-price">$9.99</span>
            </div>
            <div class="plan-duration">Hạn sử dụng: 1 tháng</div>
            <ul class="feature">
                <li>• Xem phim không giới hạn</li>
                <li>• Chất lượng HD</li>
                <li>• 2 thiết bị đồng thời</li>
                <li>• Không quảng cáo</li>
            </ul>
            <button class="buy-button">Đăng Ký Ngay</button>
        </div>
        
        <!-- Gói 6 Tháng -->
        <div class="plan-card">
            <div class="save-badge">Tiết kiệm 25%</div>
            <div class="plan-name">Gói 6 Tháng</div>
            <div class="plan-price">
                <span class="original-price">$59.94</span>
                <span class="sale-price">$49.99</span>
            </div>
            <div class="plan-duration">Hạn sử dụng: 6 tháng</div>
            <ul class="feature">
                <li>• Xem phim không giới hạn</li>
                <li>• Chất lượng HD & 4K</li>
                <li>• 3 thiết bị đồng thời</li>
                <li>• Không quảng cáo</li>
                <li>• Tải xuống offline</li>
            </ul>
            <button class="buy-button">Đăng Ký Ngay</button>
        </div>
        
        <!-- Gói 1 Năm -->
        <div class="plan-card">
            <div class="save-badge">Tiết kiệm 30%</div>
            <div class="plan-name">Gói 1 Năm</div>
            <div class="plan-price">
                <span class="original-price">$119.88</span>
                <span class="sale-price">$99.99</span>
            </div>
            <div class="plan-duration">Hạn sử dụng: 12 tháng</div>
            <ul class="feature">
                <li>• Xem phim không giới hạn</li>
                <li>• Chất lượng 4K Ultra HD</li>
                <li>• 4 thiết bị đồng thời</li>
                <li>• Không quảng cáo</li>
                <li>• Tải xuống offline</li>
                <li>• Hỗ trợ ưu tiên</li>
            </ul>
            <button class="buy-button">Đăng Ký Ngay</button>
        </div>
    </div>
</body>
</html>
