package project;

import java.sql.*;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.*;
import java.util.Vector;

public class ReportMgr {
    private DBConnectionMgr pool;

    public ReportMgr() {
        pool = DBConnectionMgr.getInstance();
    }

    // 신고 데이터를 DB에 등록하는 메서드
    public boolean insertReport(ReportBean report) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "INSERT INTO report(report_type, report_target_id, report_reason, reporter_id, reported_member_id, report_created_at, report_status) " +
                "VALUES(?,?,?,?,?, now(), '대기')";
        boolean flag = false;
        
        try {
            con = pool.getConnection();
            if (con == null) {
                System.out.println("insertReport 에러: 데이터베이스 연결 실패");
                return false;
            }
            
            pstmt = con.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS);
            pstmt.setString(1, report.getReport_type());
            pstmt.setInt(2, report.getReport_target_id());
            pstmt.setString(3, report.getReport_reason());
            pstmt.setString(4, report.getReporter_id());
            pstmt.setString(5, report.getReported_member_id());
            int cnt = pstmt.executeUpdate();
            
            if (cnt > 0) {
                flag = true;
                System.out.println("insertReport 성공: report_target_id=" + report.getReport_target_id());
                
                // 생성된 report_id 가져오기
                rs = pstmt.getGeneratedKeys();
                int reportId = 0;
                if (rs.next()) {
                    reportId = rs.getInt(1);
                }

                // 1. 피신고자에게 알림 생성
                String noticeSql1 = "INSERT INTO notice (report_id, member_id) VALUES (?, ?)";
                pstmt = con.prepareStatement(noticeSql1);
                pstmt.setInt(1, reportId);
                pstmt.setString(2, report.getReported_member_id());
                pstmt.executeUpdate();

                // 2. 신고자에게 알림 생성
                String noticeSql2 = "INSERT INTO notice (report_id, member_id) VALUES (?, ?)";
                pstmt = con.prepareStatement(noticeSql2);
                pstmt.setInt(1, reportId);
                pstmt.setString(2, report.getReporter_id());
                pstmt.executeUpdate();
                
            } else {
                System.out.println("insertReport 실패: 데이터 삽입 없음");
            }
        } catch (Exception e) {
            System.out.println("insertReport 에러: " + e.getMessage());
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt);
        }
        return flag;
    }

    // 이미 신고한 내역이 있는지 확인
    public boolean checkAlreadyReported(String reportType, int targetId, String reporterId) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        boolean exists = false;

        try {
            con = pool.getConnection();
            if (con == null) {
                System.out.println("checkAlreadyReported 에러: 데이터베이스 연결 실패");
                return false;
            }
            String sql = "SELECT COUNT(*) FROM report WHERE report_type = ? AND report_target_id = ? AND reporter_id = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, reportType);
            pstmt.setInt(2, targetId);
            pstmt.setString(3, reporterId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                int count = rs.getInt(1);
                exists = (count > 0);
                System.out.println("checkAlreadyReported: count=" + count + ", reportType=" + reportType + ", targetId=" + targetId + ", reporterId=" + reporterId);
            }
        } catch (Exception e) {
            System.out.println("checkAlreadyReported 에러: " + e.getMessage());
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt, rs);
        }

        return exists;
    }
    
    // 댓글 신고 처리
    public boolean reportComment(String reporterId, int commentId, String reportReason) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        boolean success = false;

        try {
            // 입력값 유효성 검사
            if (reporterId == null || reporterId.trim().isEmpty() || reportReason == null || reportReason.trim().isEmpty()) {
                System.out.println("reportComment 에러: reporterId 또는 reportReason이 null이거나 비어 있음");
                return false;
            }

            // DB 연결
            con = pool.getConnection();
            if (con == null) {
                System.out.println("reportComment 에러: 데이터베이스 연결 실패");
                return false;
            }

            // 이미 신고했는지 확인
            if (checkAlreadyReported("comment", commentId, reporterId)) {
                System.out.println("reportComment: 이미 신고한 댓글 - reporterId=" + reporterId + ", commentId=" + commentId);
                return false;
            }

            // 댓글 작성자 ID 가져오기
            String sql = "SELECT member_id FROM comment WHERE comment_id = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, commentId);
            rs = pstmt.executeQuery();

            String reportedMemberId = null;
            if (rs.next()) {
                reportedMemberId = rs.getString("member_id");
            } else {
                System.out.println("reportComment: 댓글이 존재하지 않음 - commentId=" + commentId);
                return false;
            }

            // 본인이 작성한 댓글인지 확인
            if (reporterId.equals(reportedMemberId)) {
                System.out.println("reportComment: 본인 댓글 신고 시도 - reporterId=" + reporterId);
                return false;
            }

            // 신고 데이터 생성 및 삽입
            ReportBean report = new ReportBean();
            report.setReport_type("comment");
            report.setReport_target_id(commentId);
            report.setReport_reason(reportReason);
            report.setReporter_id(reporterId);
            report.setReported_member_id(reportedMemberId);

            success = insertReport(report);
            if (success) {
                System.out.println("reportComment: 신고 성공 - commentId=" + commentId);
            } else {
                System.out.println("reportComment: 신고 삽입 실패 - commentId=" + commentId);
            }

        } catch (Exception e) {
            System.out.println("reportComment 에러: " + e.getMessage());
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt, rs);
        }

        return success;
    }
    
 // 필터 + 페이징 적용된 신고 목록 조회
    public Vector<ReportBean> getReportList(String status, String type, String keyword, int startRow, int pageSize) {
        Vector<ReportBean> reportList = new Vector<>();
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        StringBuilder sql = new StringBuilder("SELECT * FROM report");
        boolean whereAdded = false;

        if (status != null && !status.trim().isEmpty()) {
            sql.append(" WHERE report_status = ?");
            whereAdded = true;
        }

        if (type != null && !type.trim().isEmpty()) {
            sql.append(whereAdded ? " AND" : " WHERE");
            sql.append(" report_type = ?");
            whereAdded = true;
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(whereAdded ? " AND" : " WHERE");
            sql.append(" (report_reason LIKE ? OR reporter_id LIKE ? OR reported_member_id LIKE ?)");
        }

        sql.append(" ORDER BY report_created_at DESC LIMIT ?, ?");

        try {
            con = pool.getConnection();
            pstmt = con.prepareStatement(sql.toString());

            int paramIndex = 1;
            if (status != null && !status.trim().isEmpty()) {
                pstmt.setString(paramIndex++, status);
            }
            if (type != null && !type.trim().isEmpty()) {
                pstmt.setString(paramIndex++, type);
            }
            if (keyword != null && !keyword.trim().isEmpty()) {
                String searchKeyword = "%" + keyword + "%";
                pstmt.setString(paramIndex++, searchKeyword);
                pstmt.setString(paramIndex++, searchKeyword);
                pstmt.setString(paramIndex++, searchKeyword);
            }

            pstmt.setInt(paramIndex++, startRow);
            pstmt.setInt(paramIndex, pageSize);

            rs = pstmt.executeQuery();
            while (rs.next()) {
                ReportBean rb = new ReportBean();
                rb.setReport_id(rs.getInt("report_id"));
                rb.setReport_type(rs.getString("report_type"));
                rb.setReport_target_id(rs.getInt("report_target_id"));
                rb.setReport_reason(rs.getString("report_reason"));
                rb.setReporter_id(rs.getString("reporter_id"));
                rb.setReported_member_id(rs.getString("reported_member_id"));
                rb.setReport_created_at(rs.getTimestamp("report_created_at"));
                rb.setReport_status(rs.getString("report_status"));
                reportList.add(rb);
            }
        } catch (Exception e) {
            System.out.println("getReportList (paging) 에러: " + e.getMessage());
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt, rs);
        }

        return reportList;
    }

 // 필터 포함한 전체 신고 수
    public int getReportCount(String status, String type, String keyword) {
        int count = 0;
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM report");
        boolean whereAdded = false;

        if (status != null && !status.trim().isEmpty()) {
            sql.append(" WHERE report_status = ?");
            whereAdded = true;
        }

        if (type != null && !type.trim().isEmpty()) {
            sql.append(whereAdded ? " AND" : " WHERE");
            sql.append(" report_type = ?");
            whereAdded = true;
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(whereAdded ? " AND" : " WHERE");
            sql.append(" (report_reason LIKE ? OR reporter_id LIKE ? OR reported_member_id LIKE ?)");
        }

        try {
            con = pool.getConnection();
            pstmt = con.prepareStatement(sql.toString());

            int paramIndex = 1;
            if (status != null && !status.trim().isEmpty()) {
                pstmt.setString(paramIndex++, status);
            }
            if (type != null && !type.trim().isEmpty()) {
                pstmt.setString(paramIndex++, type);
            }
            if (keyword != null && !keyword.trim().isEmpty()) {
                String searchKeyword = "%" + keyword + "%";
                pstmt.setString(paramIndex++, searchKeyword);
                pstmt.setString(paramIndex++, searchKeyword);
                pstmt.setString(paramIndex++, searchKeyword);
            }

            rs = pstmt.executeQuery();
            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (Exception e) {
            System.out.println("getReportCount 에러: " + e.getMessage());
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt, rs);
        }

        return count;
    }

    // 게시글 신고 처리
    public boolean reportBoard(String reporterId, int boardId, String reportReason) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        boolean success = false;

        try {
            // 입력값 유효성 검사
            if (reporterId == null || reporterId.trim().isEmpty() || reportReason == null || reportReason.trim().isEmpty()) {
                System.out.println("reportBoard 에러: reporterId 또는 reportReason이 null이거나 비어 있음");
                return false;
            }

            // DB 연결
            con = pool.getConnection();
            if (con == null) {
                System.out.println("reportBoard 에러: 데이터베이스 연결 실패");
                return false;
            }

            // 이미 신고했는지 확인
            if (checkAlreadyReported("board", boardId, reporterId)) {
                System.out.println("reportBoard: 이미 신고한 게시글 - reporterId=" + reporterId + ", boardId=" + boardId);
                return false;
            }

            // 게시글 작성자 ID 가져오기
            String sql = "SELECT member_id FROM board WHERE board_id = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, boardId);
            rs = pstmt.executeQuery();

            String reportedMemberId = null;
            if (rs.next()) {
                reportedMemberId = rs.getString("member_id");
            } else {
                System.out.println("reportBoard: 게시글이 존재하지 않음 - boardId=" + boardId);
                return false;
            }

            // 본인이 작성한 게시글인지 확인
            if (reporterId.equals(reportedMemberId)) {
                System.out.println("reportBoard: 본인 게시글 신고 시도 - reporterId=" + reporterId);
                return false;
            }

            // 신고 데이터 생성 및 삽입
            ReportBean report = new ReportBean();
            report.setReport_type("board");
            report.setReport_target_id(boardId);
            report.setReport_reason(reportReason);
            report.setReporter_id(reporterId);
            report.setReported_member_id(reportedMemberId);

            success = insertReport(report);
            if (success) {
                System.out.println("reportBoard: 신고 성공 - boardId=" + boardId);
            } else {
                System.out.println("reportBoard: 신고 삽입 실패 - boardId=" + boardId);
            }

        } catch (Exception e) {
            System.out.println("reportBoard 에러: " + e.getMessage());
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt, rs);
        }

        return success;
    }
    
    // 신고 상세정보 조회
    public ReportBean getReportDetail(int report_id) {
        ReportBean bean = null;
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT report_id, report_type, report_target_id, report_reason, reporter_id, " +
                     "reported_member_id, report_created_at, report_status FROM report WHERE report_id = ?";
        try {
            con = pool.getConnection();
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, report_id);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                bean = new ReportBean();
                bean.setReport_id(rs.getInt("report_id"));
                bean.setReport_type(rs.getString("report_type"));
                bean.setReport_target_id(rs.getInt("report_target_id"));
                bean.setReport_reason(rs.getString("report_reason"));
                bean.setReporter_id(rs.getString("reporter_id"));
                bean.setReported_member_id(rs.getString("reported_member_id"));
                bean.setReport_created_at(rs.getTimestamp("report_created_at"));
                bean.setReport_status(rs.getString("report_status"));
            }
        } catch (Exception e) {
            System.out.println("getReportDetail 에러: " + e.getMessage());
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt, rs);
        }
        return bean;
    }
    
    public String getReportedContent(String type, int targetId) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String content = "";

        try {
            con = pool.getConnection();
            String sql = "";
            switch (type) {
                case "comment":
                    sql = "SELECT comment_content FROM comment WHERE comment_id = ?";
                    break;
                case "review":
                    sql = "SELECT review_comment FROM review WHERE review_id = ?";
                    break;
                case "board":
                    sql = "SELECT board_content FROM board WHERE board_id = ?";
                    break;
                default:
                    return "지원하지 않는 유형입니다.";
            }

            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, targetId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                content = rs.getString(1);
            } else {
                content = "해당 대상의 정보가 존재하지 않습니다.";
            }

        } catch (Exception e) {
            e.printStackTrace();
            content = "콘텐츠 불러오기 중 오류 발생";
        } finally {
            pool.freeConnection(con, pstmt, rs);
        }

        return content;
    }
    
    public void reportReview(String reporterId, int reviewId, String reportReason) {
    	 // 이미 신고했는지 확인
        if (checkAlreadyReported("review", reviewId, reporterId)) {
            System.out.println("reportReview: 이미 신고한 리뷰 - reporterId=" + reporterId + ", commentId=" + reviewId);
            return;
        }
        
        // 입력값 유효성 검사
        if (reporterId == null || reporterId.trim().isEmpty() || reportReason == null || reportReason.trim().isEmpty()) {
            System.out.println("reportReview 에러: reporterId 또는 reportReason이 null이거나 비어 있음");
        }
    	
    	Connection con = null;
		PreparedStatement pstmt = null;
		String sql = null;
		ResultSet rs = null;
		try {
			con = pool.getConnection();
            sql = "SELECT member_id FROM review WHERE review_id = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, reviewId);
            rs = pstmt.executeQuery();
            
            String reportedMemberId = null;
            if (rs.next()) {
                reportedMemberId = rs.getString("member_id");
            } else {
                System.out.println("reportReview: 댓글이 존재하지 않음 - reviewId=" + reviewId);
            }
            
         // 신고 데이터 생성 및 삽입
            ReportBean report = new ReportBean();
            report.setReport_type("review");
            report.setReport_target_id(reviewId);
            report.setReport_reason(reportReason);
            report.setReporter_id(reporterId);
            report.setReported_member_id(reportedMemberId);
            if (insertReport(report)) {
				System.out.println("Review 신고 성공");
			}

		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pool.freeConnection(con, pstmt);
		}
    }
    
    public int getRestaurantIdByReview(int reviewId) {
    	Connection con = null;
		PreparedStatement pstmt = null;
		String sql = null;
		ResultSet rs = null;
        int rstId = 0;
        try {
        	con = pool.getConnection();
            sql = "SELECT rst_id FROM review WHERE review_id = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, reviewId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                rstId = rs.getInt("rst_id");
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
        	pool.freeConnection(con, pstmt);
        }
        return rstId;
    }
    
    public boolean deleteReport(int reportId) {
        Connection con = null;
        PreparedStatement pstmt = null;
        boolean success = false;
        String sql = "DELETE FROM report WHERE report_id = ?";
        try {
            con = pool.getConnection();
            if (con == null) {
                System.out.println("deleteReport 에러: 데이터베이스 연결 실패");
                return false;
            }
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, reportId);
            int cnt = pstmt.executeUpdate();
            if (cnt > 0) {
                success = true;
                System.out.println("deleteReport 성공: report_id=" + reportId);
            } else {
                System.out.println("deleteReport 실패: 삭제된 행 없음 - report_id=" + reportId);
            }
        } catch (Exception e) {
            System.out.println("deleteReport 에러: " + e.getMessage());
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt);
        }
        return success;
    }

    public boolean processReport(int reportId) {
        // 신고 처리를 완료하는 로직을 구현합니다. 신고 상태를 '완료'로 업데이트 후
        // 신고된 사용자에게 제한 시간을 설정합니다.
        Connection con = null;
        PreparedStatement pstmt = null;
        boolean result = false;

        try {
            con = pool.getConnection();

            // 신고 상태를 '완료'로 업데이트
            String updateReportSql = "UPDATE report SET report_status = '완료' WHERE report_id = ?";
            pstmt = con.prepareStatement(updateReportSql);
            pstmt.setInt(1, reportId);
            int count = pstmt.executeUpdate();
            
            // 신고 처리 완료 후 제한 설정
            if (count > 0) {
                // 1. 신고된 사용자의 ID 가져오기
                String reportedMemberId = getReportedMemberId(reportId, con);
                
                if (reportedMemberId != null) {
                    // 2. 제한 설정 메서드 호출
                    applyRestrictions(reportedMemberId, con);
                    result = true;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt);
        }

        return result;
    }

    private String getReportedMemberId(int reportId, Connection con) throws SQLException {
        // 신고된 사용자의 ID를 가져오는 메서드
        String reportedMemberId = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            String sql = "SELECT reported_member_id FROM report WHERE report_id = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, reportId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                reportedMemberId = rs.getString("reported_member_id");
            }
        } finally {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
        }
        return reportedMemberId;
    }

    private void applyRestrictions(String reportedMemberId, Connection con) {
        // 신고된 사용자에 대한 제한을 3일 후로 설정하는 메서드
        PreparedStatement pstmt = null;

        try {
            // 3일 후의 날짜 계산
            Calendar cal = Calendar.getInstance();
            cal.add(Calendar.DATE, 3); // 3일 후
            Timestamp restrictionEnd = new Timestamp(cal.getTimeInMillis());

            // 게시글, 댓글, 리뷰 작성 제한 설정
            String sql = "UPDATE member SET ban_post_until = ?, ban_comment_until = ?, ban_review_until = ? WHERE member_id = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setTimestamp(1, restrictionEnd); // 게시글 작성 제한
            pstmt.setTimestamp(2, restrictionEnd); // 댓글 작성 제한
            pstmt.setTimestamp(3, restrictionEnd); // 리뷰 작성 제한
            pstmt.setString(4, reportedMemberId);  // 신고된 사용자의 ID

            pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (pstmt != null) {
                try {
                    pstmt.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }


}
