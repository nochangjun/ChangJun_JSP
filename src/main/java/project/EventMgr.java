package project;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Vector;

public class EventMgr {

	private DBConnectionMgr pool;

	public EventMgr() {
		pool = DBConnectionMgr.getInstance();
	}

	// 이벤트 등록
	public boolean insertEvent(EventBean bean) {
		Connection con = null;
		PreparedStatement pstmt = null;
		boolean result = false;

		try {
			con = pool.getConnection();

			// 현재 날짜
			LocalDate today = LocalDate.now();
			LocalDate start = LocalDate.parse(bean.getStartDate());
			LocalDate end = LocalDate.parse(bean.getEndDate());

			String status;
			if (today.isBefore(start)) {
				status = "예정";
			} else if (!today.isAfter(end)) {
				status = "진행중";
			} else {
				status = "종료";
			}

			String sql = "INSERT INTO event (title, content, image_url, start_date, end_date, status, admin_id) "
			           + "VALUES (?, ?, ?, ?, ?, ?, ?)";
			pstmt = con.prepareStatement(sql);
			pstmt.setString(1, bean.getTitle());
			pstmt.setString(2, bean.getContent());
			pstmt.setString(3, bean.getImageUrl());
			pstmt.setString(4, bean.getStartDate());
			pstmt.setString(5, bean.getEndDate());
			pstmt.setString(6, status); // 자동으로 계산된 상태 저장
			pstmt.setString(7, bean.getAdminId());

			result = pstmt.executeUpdate() > 0;

		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pool.freeConnection(con, pstmt);
		}
		return result;
	}



	public Vector<EventBean> getVisibleEvents() {
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String sql = "SELECT * FROM event ORDER BY start_date DESC";
		Vector<EventBean> list = new Vector<>();

		try {
			con = pool.getConnection();
			pstmt = con.prepareStatement(sql);
			rs = pstmt.executeQuery();
			while (rs.next()) {
				EventBean bean = new EventBean();
				bean.setEventId(rs.getInt("event_id"));
				bean.setTitle(rs.getString("title"));
				bean.setContent(rs.getString("content"));
				bean.setImageUrl(rs.getString("image_url"));
				bean.setStartDate(rs.getString("start_date"));
				bean.setEndDate(rs.getString("end_date"));
				bean.setStatus(rs.getString("status"));
				list.add(bean);
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pool.freeConnection(con, pstmt, rs);
		}
		return list;
	}
	
	// 이벤트 삭제
	public boolean deleteEvent(int eventId) {
	    Connection con = null;
	    PreparedStatement pstmt = null;
	    boolean success = false;
	    String sql = "DELETE FROM event WHERE event_id = ?";

	    try {
	        con = pool.getConnection();
	        pstmt = con.prepareStatement(sql);
	        pstmt.setInt(1, eventId);
	        success = pstmt.executeUpdate() > 0;
	    } catch (Exception e) {
	        e.printStackTrace();
	    } finally {
	        pool.freeConnection(con, pstmt);
	    }

	    return success;
	}

	public Vector<EventBean> getEventsByStatus(String status, int start, int count) {
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String sql = "SELECT * FROM event WHERE status = ? ORDER BY start_date DESC LIMIT ?, ?";
		Vector<EventBean> list = new Vector<>();
		try {
			con = pool.getConnection();
			pstmt = con.prepareStatement(sql);
			pstmt.setString(1, status);
			pstmt.setInt(2, start);
			pstmt.setInt(3, count);
			rs = pstmt.executeQuery();
			while (rs.next()) {
				EventBean bean = new EventBean();
				bean.setEventId(rs.getInt("event_id"));
				bean.setTitle(rs.getString("title"));
				bean.setContent(rs.getString("content"));
				bean.setImageUrl(rs.getString("image_url"));
				bean.setStartDate(rs.getString("start_date"));
				bean.setEndDate(rs.getString("end_date"));
				bean.setStatus(rs.getString("status"));
				list.add(bean);
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pool.freeConnection(con, pstmt, rs);
		}
		return list;
	}

	public int countEventsByStatus(String status) {
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		int total = 0;
		String sql = "SELECT COUNT(*) FROM event WHERE status = ?";
		try {
			con = pool.getConnection();
			pstmt = con.prepareStatement(sql);
			pstmt.setString(1, status);
			rs = pstmt.executeQuery();
			if (rs.next()) {
				total = rs.getInt(1);
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pool.freeConnection(con, pstmt, rs);
		}
		return total;
	}

	public Vector<EventBean> searchEvents(String category, String keyword) {
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String sql = "SELECT * FROM event ";
		if (category.equals("제목")) {
			sql += "WHERE title LIKE ?";
		} else if (category.equals("내용")) {
			sql += "WHERE content LIKE ?";
		} else {
			sql += "WHERE title LIKE ? OR content LIKE ?";
		}

		Vector<EventBean> list = new Vector<>();
		try {
			con = pool.getConnection();
			pstmt = con.prepareStatement(sql);

			if (category.equals("전체")) {
				pstmt.setString(1, "%" + keyword + "%");
				pstmt.setString(2, "%" + keyword + "%");
			} else {
				pstmt.setString(1, "%" + keyword + "%");
			}

			rs = pstmt.executeQuery();
			while (rs.next()) {
				EventBean bean = new EventBean();
				bean.setEventId(rs.getInt("event_id"));
				bean.setTitle(rs.getString("title"));
				bean.setContent(rs.getString("content"));
				bean.setImageUrl(rs.getString("image_url"));
				bean.setStartDate(rs.getString("start_date"));
				bean.setEndDate(rs.getString("end_date"));
				bean.setStatus(rs.getString("status"));
				list.add(bean);
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pool.freeConnection(con, pstmt, rs);
		}
		return list;
	}

	// 특정 ID로 이벤트 1개 가져오기
	public EventBean getEventById(int eventId) {
	    Connection con = null;
	    PreparedStatement pstmt = null;
	    ResultSet rs = null;
	    String sql = "SELECT * FROM event WHERE event_id = ?";
	    EventBean bean = new EventBean();

	    try {
	        con = pool.getConnection();
	        pstmt = con.prepareStatement(sql);
	        pstmt.setInt(1, eventId);
	        rs = pstmt.executeQuery();

	        if (rs.next()) {
	            bean.setEventId(rs.getInt("event_id"));
	            bean.setTitle(rs.getString("title"));
	            bean.setContent(rs.getString("content"));
	            bean.setImageUrl(rs.getString("image_url"));
	            bean.setStartDate(rs.getString("start_date"));
	            bean.setEndDate(rs.getString("end_date"));
	            bean.setViews(rs.getInt("views"));
	            bean.setAdminId(rs.getString("admin_id"));
	        }
	    } catch (Exception e) {
	        e.printStackTrace();
	    } finally {
	        pool.freeConnection(con, pstmt, rs);
	    }

	    return bean;
	}
	
	// 조회수 1 증가
	public void increaseViews(int eventId) {
	    Connection con = null;
	    PreparedStatement pstmt = null;
	    String sql = "UPDATE event SET views = views + 1 WHERE event_id = ?";
	    try {
	        con = pool.getConnection();
	        pstmt = con.prepareStatement(sql);
	        pstmt.setInt(1, eventId);
	        pstmt.executeUpdate();
	    } catch (Exception e) {
	        e.printStackTrace();
	    } finally {
	        pool.freeConnection(con, pstmt);
	    }
	}
	
	// 이벤트 상태 일괄 업데이트
	public void updateEventStatuses() {
		Connection con = null;
		PreparedStatement pstmt = null;
		String sql = "UPDATE event \n"
				   + "SET status = CASE \n"
				   + "  WHEN NOW() < start_date THEN '예정' \n"
				   + "  WHEN NOW() BETWEEN start_date AND end_date THEN '진행중' \n"
				   + "  WHEN NOW() > end_date THEN '종료' \n"
				   + "END";
		try {
			con = pool.getConnection();
			pstmt = con.prepareStatement(sql);
			pstmt.executeUpdate();
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pool.freeConnection(con, pstmt);
		}
	}
	
	// 진행중인 이벤트를 시작일 기준 오름차순으로 가져오기
	public List<EventBean> getRecentEvents(int limit) {
	    List<EventBean> list = new ArrayList<>();
	    Connection con = null;
	    PreparedStatement pstmt = null;
	    ResultSet rs = null;
	    String sql = "SELECT * FROM event WHERE status = '진행중' ORDER BY start_date ASC LIMIT ?";
	    
	    try {
	        con = pool.getConnection();
	        pstmt = con.prepareStatement(sql);
	        pstmt.setInt(1, limit);
	        rs = pstmt.executeQuery();

	        while (rs.next()) {
	            EventBean bean = new EventBean();
	            bean.setEventId(rs.getInt("event_id"));
	            bean.setTitle(rs.getString("title"));
	            bean.setContent(rs.getString("content"));
	            bean.setImageUrl(rs.getString("image_url"));
	            bean.setStartDate(rs.getString("start_date"));
	            bean.setEndDate(rs.getString("end_date"));
	            bean.setAdminId(rs.getString("admin_id"));
	            bean.setStatus(rs.getString("status"));
	            list.add(bean);
	        }
	    } catch (Exception e) {
	        e.printStackTrace();
	    } finally {
	        pool.freeConnection(con, pstmt, rs);
	    }
	    return list;
	}


}
