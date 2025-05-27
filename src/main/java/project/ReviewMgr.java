package project;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Vector;

public class ReviewMgr {
	private DBConnectionMgr pool;
	
	public ReviewMgr() {
		pool = DBConnectionMgr.getInstance();
	}
	
	// 리뷰 등록
	public void insertReview(ReviewBean bean) {
		Connection con = null;
		PreparedStatement pstmt = null;
		String sql = null;
		try {
			con = pool.getConnection();
			sql = "INSERT INTO review (review_comment, review_menu, review_rating, rst_id, member_id) VALUES (?,?,?,?,?)";
			pstmt = con.prepareStatement(sql);
			pstmt.setString(1, bean.review_comment);
			pstmt.setString(2, bean.getReview_menu());
			pstmt.setDouble(3, bean.getReview_rating());
			pstmt.setInt(4, bean.getRst_id());
			pstmt.setString(5, bean.getMember_id());
			pstmt.executeUpdate();
			System.out.println("insertReview");
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pool.freeConnection(con, pstmt);
		}
	}
	
	// 리뷰 id값 찾기
	public int searchReviewId(String rst_id, String member_id) {
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String sql = null;
		int review_id = 0;
		try {
			con = pool.getConnection();
			sql = "select review_id from review where rst_id = ? and member_id = ?";
			pstmt = con.prepareStatement(sql);
			pstmt.setString(1, rst_id);
			pstmt.setString(2, member_id);
			rs = pstmt.executeQuery();
			if (rs.next()) {
				review_id = Integer.parseInt(rs.getString(1));
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pool.freeConnection(con, pstmt, rs);
		}
		return review_id;
	}
	
	//리뷰이미지 insert
	public void insertReviewImage(ReviewBean bean, String str) {
		Connection con = null;
		PreparedStatement pstmt = null;
		String sql = null;
		try {
			con = pool.getConnection();
			sql = "INSERT INTO r_image (r_image, reivew_id) VALUES (?,?)";
			pstmt = con.prepareStatement(sql);
			pstmt.setString(1, str);
			pstmt.setInt(2, bean.getReview_id());

			pstmt.executeUpdate();
			System.out.println("insert 이미지");

		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pool.freeConnection(con, pstmt);
		}
	}
	
	//rst_id로 리뷰리스트 검색 + 리뷰이미지
	public Vector<ReviewBean> searchReview(int rst_id, String sort) {
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String sql = null;
		PreparedStatement imgPstmt = null; // 이미지용
		ResultSet imgRs = null;
		Vector<ReviewBean> vlist = new Vector<ReviewBean>();
		
		 sql = "SELECT * FROM review WHERE rst_id = ? ";
		    
		    if ("latest".equals(sort)) {
		        sql += "ORDER BY review_create_at DESC";
		    } else if ("high".equals(sort)) {
		        sql += "ORDER BY review_rating DESC, review_create_at DESC";
		    } else if ("low".equals(sort)) {
		        sql += "ORDER BY review_rating ASC, review_create_at DESC";
		    }
		try {
			con = pool.getConnection();
			pstmt = con.prepareStatement(sql);
			pstmt.setInt(1, rst_id);
			rs = pstmt.executeQuery();
			while (rs.next()) {
				ReviewBean bean = new ReviewBean();
				bean.setReview_id(Integer.parseInt(rs.getString("review_id")));
				bean.setReview_comment(rs.getString("review_comment"));
				bean.setReview_create_at(rs.getString("review_create_at"));
				bean.setReview_menu(rs.getString("review_menu"));
				bean.setReview_rating(Double.parseDouble(rs.getString("review_rating")));
				bean.setRst_id(rs.getInt("rst_id"));
				bean.setMember_id(rs.getString("member_id"));
				bean.setReview_like(rs.getInt("review_like"));
				
				// 이미지 리스트 가져오기
				String imgSql = "SELECT r_image FROM r_image WHERE reivew_id = ?";
				imgPstmt = con.prepareStatement(imgSql);
				imgPstmt.setInt(1, bean.getReview_id());
				imgRs = imgPstmt.executeQuery();

				Vector<String> imgList = new Vector<>();
				while (imgRs.next()) {
					imgList.add(imgRs.getString("r_image"));
				}
				bean.setImgList(imgList); // 이미지 리스트 설정

				vlist.add(bean); // 벡터에 추가

				if (imgRs != null) imgRs.close();
				if (imgPstmt != null) imgPstmt.close();
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pool.freeConnection(con, pstmt, rs);
		}
		return vlist;
	}
	
	//rst_id로 전체리뷰 count
		public int ReviewCount(int rst_id) {
			Connection con = null;
			PreparedStatement pstmt = null;
			ResultSet rs = null;
			String sql = null;
			int rCnt = 0;
			try {
				con = pool.getConnection();
				sql = "select count(review_id) from review where rst_id = ?";
				pstmt = con.prepareStatement(sql);
				pstmt.setInt(1, rst_id);
				rs = pstmt.executeQuery();
				if (rs.next()) {
					rCnt = Integer.parseInt(rs.getString(1));
				}
			} catch (Exception e) {
				e.printStackTrace();
			} finally {
				pool.freeConnection(con, pstmt, rs);
			}
			return rCnt;
		}
		
		//member_id로 전체리뷰 count
			public int ReviewCount(String member_id) {
				Connection con = null;
				PreparedStatement pstmt = null;
				ResultSet rs = null;
				String sql = null;
				int rCnt = 0;
				try {
					con = pool.getConnection();
					sql = "select count(review_id) from review where member_id = ?";
					pstmt = con.prepareStatement(sql);
					pstmt.setString(1, member_id);
					rs = pstmt.executeQuery();
					if (rs.next()) {
						rCnt = Integer.parseInt(rs.getString(1));
					}
				} catch (Exception e) {
					e.printStackTrace();
				} finally {
					pool.freeConnection(con, pstmt, rs);
				}
				return rCnt;
			}
	
	public int ReviewRatingCount(int rst_id, int rating) {
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String sql = null;
		int ratingCount = 0;
		try {
			con = pool.getConnection();
			sql = "SELECT count(*) FROM review WHERE rst_id = ? AND review_rating = ?;";
			pstmt = con.prepareStatement(sql);
			pstmt.setInt(1, rst_id);
			pstmt.setInt(2, rating);
			rs = pstmt.executeQuery();
			if (rs.next()) {
				ratingCount = Integer.parseInt(rs.getString(1));
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pool.freeConnection(con, pstmt, rs);
		}
		return ratingCount;
	}
	
	public Vector<ReviewBean> searchReview(int rst_id, String sort, int start, int count) {
	    Vector<ReviewBean> v = new Vector<>();
		Connection con = null;
		PreparedStatement imgPstmt = null; // 이미지용
		ResultSet imgRs = null;
	    try {
	        Connection conn = pool.getConnection();
	        String orderBy = "review_create_at DESC";
	        if ("high".equals(sort)) orderBy = "review_rating DESC";
	        else if ("low".equals(sort)) orderBy = "review_rating ASC";

	        String sql = "SELECT * FROM review WHERE rst_id = ? ORDER BY " + orderBy + " LIMIT ?, ?";
	        PreparedStatement pstmt = conn.prepareStatement(sql);
	        pstmt.setInt(1, rst_id);
	        pstmt.setInt(2, start);
	        pstmt.setInt(3, count);

	        ResultSet rs = pstmt.executeQuery();
	        while (rs.next()) {
	            ReviewBean bean = new ReviewBean();
	            bean.setReview_id(Integer.parseInt(rs.getString("review_id")));
				bean.setReview_comment(rs.getString("review_comment"));
				bean.setReview_create_at(rs.getString("review_create_at"));
				bean.setReview_menu(rs.getString("review_menu"));
				bean.setReview_rating(Double.parseDouble(rs.getString("review_rating")));
				bean.setRst_id(rs.getInt("rst_id"));
				bean.setMember_id(rs.getString("member_id"));
				bean.setReview_like(rs.getInt("review_like"));
				
				// 이미지 리스트 가져오기
				String imgSql = "SELECT r_image FROM r_image WHERE reivew_id = ?";
				imgPstmt = conn.prepareStatement(imgSql);
				imgPstmt.setInt(1, bean.getReview_id());
				imgRs = imgPstmt.executeQuery();

				Vector<String> imgList = new Vector<>();
				while (imgRs.next()) {
					imgList.add(imgRs.getString("r_image"));
				}
				bean.setImgList(imgList); // 이미지 리스트 설정
				
	            v.add(bean);
	        }
	        rs.close(); pstmt.close(); conn.close();
	    } catch (Exception e) {
	        e.printStackTrace();
	    }
	    return v;
	}
	
	public boolean deleteReview(int reviewId) {
        Connection con = null;
        PreparedStatement pstmt = null;
        boolean success = false;
        String sql = "DELETE FROM review WHERE review_id = ?";
        
        try {
            con = pool.getConnection();
            if (con == null) {
                System.out.println("deleteReview 에러: 데이터베이스 연결 실패");
                return false;
            }
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, reviewId);
            int cnt = pstmt.executeUpdate();
            if (cnt > 0) {
                success = true;
                System.out.println("deleteReview 성공: review_id=" + reviewId);
            } else {
                System.out.println("deleteReview 실패: 삭제된 행 없음 - review_id=" + reviewId);
            }
        } catch (Exception e) {
            System.out.println("deleteReview 에러: " + e.getMessage());
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt);
        }
        return success;
    }
	
	public Vector<ReviewBean> getReviewsByMember(String memberId, int start, int pageSize) {
	    Connection con = null;
	    PreparedStatement pstmt = null;
	    ResultSet rs = null;
	    PreparedStatement imgPstmt = null;
	    ResultSet imgRs = null;
	    Vector<ReviewBean> vlist = new Vector<>();

	    try {
	        con = pool.getConnection();
	        String sql = "SELECT * FROM review WHERE member_id = ? ORDER BY review_create_at DESC LIMIT ?, ?";
	        pstmt = con.prepareStatement(sql);
	        pstmt.setString(1, memberId);
	        pstmt.setInt(2, start);
	        pstmt.setInt(3, pageSize);
	        rs = pstmt.executeQuery();

	        while (rs.next()) {
	            ReviewBean bean = new ReviewBean();
	            bean.setReview_id(rs.getInt("review_id"));
	            bean.setReview_comment(rs.getString("review_comment"));
	            bean.setReview_create_at(rs.getString("review_create_at"));
	            bean.setReview_menu(rs.getString("review_menu"));
	            bean.setReview_rating(rs.getDouble("review_rating"));
	            bean.setRst_id(rs.getInt("rst_id"));
	            bean.setMember_id(rs.getString("member_id"));
	            bean.setReview_like(rs.getInt("review_like"));

	            // 이미지 리스트 가져오기
	            String imgSql = "SELECT r_image FROM r_image WHERE reivew_id = ?";
	            imgPstmt = con.prepareStatement(imgSql);
	            imgPstmt.setInt(1, bean.getReview_id());
	            imgRs = imgPstmt.executeQuery();

	            Vector<String> imgList = new Vector<>();
	            while (imgRs.next()) {
	                imgList.add(imgRs.getString("r_image"));
	            }
	            bean.setImgList(imgList);

	            vlist.add(bean);

	            if (imgRs != null) imgRs.close();	
	            if (imgPstmt != null) imgPstmt.close();
	        }

	    } catch (Exception e) {
	        e.printStackTrace();
	    } finally {
	        pool.freeConnection(con, pstmt, rs);
	    }

	    return vlist;
	}


}
