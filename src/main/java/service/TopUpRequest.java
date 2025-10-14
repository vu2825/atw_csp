package service;

import java.util.Date;
import types.*;

public class TopUpRequest {
	private int id;
	private int user_id;
	private double amount;
	private TopUpRequestTypes status;
	private Date created_at;
	private Date updated_at;

	public TopUpRequest(int id, int user_id, double amount, TopUpRequestTypes status, Date created_at, Date updated_at) {
		super();
		this.id = id;
		this.user_id = user_id;
		this.amount = amount;
		this.status = status;
		this.created_at = created_at;
		this.updated_at = updated_at;
	}

	public TopUpRequest() {

	}

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public int getUser_id() {
		return user_id;
	}

	public void setUser_id(int user_id) {
		this.user_id = user_id;
	}

	public double getAmount() {
		return amount;
	}

	public void setAmount(double amount) {
		this.amount = amount;
	}

	public TopUpRequestTypes getStatus() {
		return status;
	}

	public void setStatus(TopUpRequestTypes status) {
		this.status = status;
	}

	public Date getCreated_at() {
		return created_at;
	}

	public void setCreated_at(Date created_at) {
		this.created_at = created_at;
	}

	public Date getUpdated_at() {
		return updated_at;
	}

	public void setUpdated_at(Date updated_at) {
		this.updated_at = updated_at;
	}

}
