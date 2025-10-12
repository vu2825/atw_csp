package service;

import java.util.Date;

import types.SubscriptionStatus;

public class UsersSubscription {
	public int id;
	public int user_id;
	public String plan;
	public double price;
	public Date started_at;
	public Date expires_at;
	public SubscriptionStatus status;

	public UsersSubscription(int id, int user_id, String plan, double price, Date started_at, Date expires_at,
			SubscriptionStatus status) {
		this.id = id;
		this.user_id = user_id;
		this.plan = plan;
		this.price = price;
		this.started_at = started_at;
		this.expires_at = expires_at;
		this.status = status;
	}

	public UsersSubscription() {

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

	public String getPlan() {
		return plan;
	}

	public void setPlan(String plan) {
		this.plan = plan;
	}

	public double getPrice() {
		return price;
	}

	public void setPrice(double price) {
		this.price = price;
	}

	public Date getStarted_at() {
		return started_at;
	}

	public void setStarted_at(Date started_at) {
		this.started_at = started_at;
	}

	public Date getExpires_at() {
		return expires_at;
	}

	public void setExpires_at(Date expires_at) {
		this.expires_at = expires_at;
	}

	public SubscriptionStatus getStatus() {
		return status;
	}

	public void setStatus(SubscriptionStatus status) {
		this.status = status;
	}

}
