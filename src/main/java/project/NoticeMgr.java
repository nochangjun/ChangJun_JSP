package project;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class NoticeMgr {
	private DBConnectionMgr pool;

    public NoticeMgr() {
        try {
            pool = DBConnectionMgr.getInstance(); // 커넥션 풀 초기화
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 특정 회원의 알림 목록을 가져오는 메서드
    public List<NoticeBean> getNoticesByMemberId(String memberId) {
        List<NoticeBean> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = pool.getConnection();

            String sql = "SELECT n.*, i.inq_title, b.member_id AS board_writer_id, " +
                            "b.board_id, b.board_title, " +
                            "CASE WHEN c.parent_comment_id IS NULL THEN 0 ELSE 1 END AS is_reply, " +
                            "r.report_type, r.report_status, r.reporter_id, r.reported_member_id " +
                            "FROM notice n " +
                            "LEFT JOIN inquiry i ON n.inq_id = i.inq_id " +
                            "LEFT JOIN comment c ON n.comment_id = c.comment_id " +
                            "LEFT JOIN board b ON c.board_id = b.board_id " +
                            "LEFT JOIN report r ON n.report_id = r.report_id " +
                            "WHERE n.member_id = ? " +
                            "ORDER BY n.notice_id DESC";

            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, memberId);

            rs = pstmt.executeQuery();
            while (rs.next()) {
                NoticeBean bean = new NoticeBean();

                // 필수 정보
                bean.setNotice_id(rs.getInt("notice_id"));
                bean.setIs_read(rs.getInt("is_read"));
                bean.setComment_id(rs.getInt("comment_id"));
                bean.setInq_id(rs.getInt("inq_id"));
                bean.setReport_id(rs.getInt("report_id"));
                Object rstIdObj = rs.getObject("rst_id");
                bean.setRst_id(rstIdObj != null ? rs.getInt("rst_id") : 0);

                // 추가 정보
                bean.setInq_title(rs.getString("inq_title"));
                bean.setStatus_info(rs.getString("status_info"));
                bean.setBoard_writer_id(rs.getString("board_writer_id"));
                bean.setBoard_id(rs.getInt("board_id"));
                bean.setBoard_title(rs.getString("board_title"));
                bean.setIsReply(rs.getInt("is_reply") == 1);

                // 신고 처리 상태 확인하여 맞는 알림 생성
                if ("완료".equals(rs.getString("report_status"))) {
                    // 신고 처리 완료
                    if (memberId.equals(rs.getString("reported_member_id"))) {
                        // 신고당한 사용자에게 알림 보내기
                        String message = rs.getString("reported_member_id") + " 님의 부적절한 콘텐츠 등록으로 인해 3일 제제 되었습니다.";
                        bean.setStatus_info(message);
                    } else if (memberId.equals(rs.getString("reporter_id"))) {
                        // 신고한 사용자에게 알림 보내기
                        String reportedMemberName = rs.getString("reported_member_id"); // 신고당한 사용자 이름 가져오기
                        String message = reportedMemberName + "님의 게시물의 신고건이 처리 완료 되었습니다.";
                        bean.setStatus_info(message);
                    }
                }

                bean.setReport_type(rs.getString("report_type"));
                bean.setReport_status(rs.getString("report_status"));
                bean.setReporter_id(rs.getString("reporter_id"));
                bean.setReported_member_id(rs.getString("reported_member_id"));

                list.add(bean);
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, pstmt, rs);
        }

        return list;
    }

    // 새로운 알림이 하나라도 존재하는지 확인하는 메서드
    public boolean hasNewNotice(String memberId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        boolean hasNew = false;

        try {
            conn = pool.getConnection();
            String sql = "SELECT COUNT(*) FROM notice WHERE member_id = ? AND is_read = 0";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, memberId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                hasNew = rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, pstmt, rs);
        }

        return hasNew;
    }
    
    /*
    // 알림을 읽음 처리하는 메서드
    public void markNoticeAsRead(int noticeId) {
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = pool.getConnection();
            String sql = "UPDATE notice SET is_read = 1 WHERE notice_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, noticeId);
            pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, pstmt);
        }
    }
    */
    
    // 모든 알림을 읽음 처리
    public void markAllNoticesAsRead(String memberId) {
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = pool.getConnection();
            String sql = "UPDATE notice SET is_read = 1 WHERE member_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, memberId);
            pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, pstmt);
        }
    }
    
    // 알림 삭제 메서드
    public void deleteNotice(int noticeId) {
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = pool.getConnection();
            String sql = "DELETE FROM notice WHERE notice_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, noticeId);
            pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, pstmt);
        }
    }
}
