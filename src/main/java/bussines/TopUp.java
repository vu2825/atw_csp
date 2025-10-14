package bussines;

import java.util.Date;
import types.TopUpRequestTypes;

public class TopUp {
	private int id;
	private int userId;
	private double amount;
	private Date createdAt;
	private Date updatedAt;
	private TopUpRequestTypes status;
	private String note;

	public TopUp() {
	}

	public TopUp(int id, int userId, double amount, Date createdAt, Date updatedAt, TopUpRequestTypes status,
			String note) {
		super();
		this.id = id;
		this.userId = userId;
		this.amount = amount;
		this.createdAt = createdAt;
		this.updatedAt = updatedAt;
		this.status = status;
		this.note = note;
	}

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public int getUserId() {
		return userId;
	}

	public void setUserId(int userId) {
		this.userId = userId;
	}

	public double getAmount() {
		return amount;
	}

	public void setAmount(double amount) {
		this.amount = amount;
	}

	public Date getCreatedAt() {
		return createdAt;
	}

	public void setCreatedAt(Date createdAt) {
		this.createdAt = createdAt;
	}

	public Date getUpdatedAt() {
		return updatedAt;
	}

	public void setUpdatedAt(Date updatedAt) {
		this.updatedAt = updatedAt;
	}

	public TopUpRequestTypes getStatus() {
		return status;
	}

	public void setStatus(TopUpRequestTypes status) {
		this.status = status;
	}

	public String getNote() {
		return note;
	}

	public void setNote(String note) {
		this.note = note;
	}
}
