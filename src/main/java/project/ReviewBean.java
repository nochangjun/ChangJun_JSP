package project;

import java.util.Vector;

public class ReviewBean {

	int review_id;
	String review_comment;
	String review_create_at;
	String review_menu;
	double review_rating;
	int rst_id;
	String member_id;
	private Vector<String> imgList;
	int review_like;
	
	public int getReview_like() {
		return review_like;
	}
	public void setReview_like(int review_like) {
		this.review_like = review_like;
	}
	public Vector<String> getImgList() {
		return imgList;
	}
	public void setImgList(Vector<String> imgList) {
		this.imgList = imgList;
	}
	public int getReview_id() {
		return review_id;
	}
	public void setReview_id(int review_id) {
		this.review_id = review_id;
	}
	public String getReview_comment() {
		return review_comment;
	}
	public void setReview_comment(String review_comment) {
		this.review_comment = review_comment;
	}
	public String getReview_create_at() {
		return review_create_at;
	}
	public void setReview_create_at(String review_create_at) {
		this.review_create_at = review_create_at;
	}
	public String getReview_menu() {
		return review_menu;
	}
	public void setReview_menu(String review_menu) {
		this.review_menu = review_menu;
	}
	public double getReview_rating() {
		return review_rating;
	}
	public void setReview_rating(double review_rating) {
		this.review_rating = review_rating;
	}
	public int getRst_id() {
		return rst_id;
	}
	public void setRst_id(int rst_id) {
		this.rst_id = rst_id;
	}
	public String getMember_id() {
		return member_id;
	}
	public void setMember_id(String member_id) {
		this.member_id = member_id;
	}
	
	
}
