package project;

import java.sql.*;

public class AdminDashboardMgr {
    private DBConnectionMgr pool;

    public AdminDashboardMgr() {
        pool = DBConnectionMgr.getInstance();
    }

    public int getUserCount() {
        return getCount("SELECT COUNT(*) FROM member");
    }

    public int getReportCount() {
        return getCount("SELECT COUNT(*) FROM report WHERE report_status = '대기'");
    }

    public int getStoreCount() {
        return getCount("SELECT COUNT(*) FROM restaurant");
    }

    public int getInquiryCount() {
        return getCount("SELECT COUNT(*) FROM inquiry");
    }

    public int getPendingStoreCount() {
        return getCount("SELECT COUNT(*) FROM restaurant WHERE rst_status = '대기'");
    }

    public int getPendingInquiryCount() {
        return getCount("SELECT COUNT(*) FROM inquiry WHERE inq_status = '대기중'");
    }

    private int getCount(String sql) {
        int count = 0;
        try (Connection con = pool.getConnection();
             PreparedStatement pstmt = con.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) count = rs.getInt(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return count;
    }

    // 최신 사용자 1명
    public MemberBean getLatestUser() {
        MemberBean bean = null;
        String sql = "SELECT * FROM member ORDER BY member_create_at DESC LIMIT 1";
        try (Connection con = pool.getConnection();
             PreparedStatement pstmt = con.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
                bean = new MemberBean();
                bean.setMember_name(rs.getString("member_name"));
                bean.setMember_id(rs.getString("member_id"));
                bean.setMember_email(rs.getString("member_email"));
                bean.setMember_create_at(rs.getString("member_create_at"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return bean;
    }

    // 최신 신고 대기중 1건
    public ReportBean getLatestPendingReport() {
        ReportBean bean = null;
        String sql = "SELECT r.*, m.member_name " +
                     "FROM report r " +
                     "JOIN member m ON r.reported_member_id = m.member_id " +
                     "WHERE r.report_status = '대기' " +
                     "ORDER BY r.report_created_at DESC LIMIT 1";
        try (Connection con = pool.getConnection();
             PreparedStatement pstmt = con.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
                bean = new ReportBean();
                bean.setReport_id(rs.getInt("report_id"));
                bean.setMember_name(rs.getString("member_name"));
                bean.setReported_member_id(rs.getString("reported_member_id"));
                bean.setReport_reason(rs.getString("report_reason"));
                bean.setReport_created_at(rs.getTimestamp("report_created_at"));
                bean.setReport_status(rs.getString("report_status")); // 🔁 이 줄도 필요
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return bean;
    }


    // 최신 대기 상태 가게 1개
    public RestaurantBean getLatestRestaurant() {
        RestaurantBean bean = null;
        String sql = "SELECT * FROM restaurant WHERE rst_status = '대기' ORDER BY created_at DESC LIMIT 1";
        try (Connection con = pool.getConnection();
             PreparedStatement pstmt = con.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
                bean = new RestaurantBean();
                bean.setRst_id(rs.getInt("rst_id"));
                bean.setRst_name(rs.getString("rst_name"));
                bean.setRegionLabel(rs.getString("regionLabel"));
                bean.setCreated_at(rs.getString("created_at"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return bean;
    }


    // 최신 대기중 문의 1건
    public InquiryBean getLatestInquiry() {
        InquiryBean bean = null;
        String sql = "SELECT i.*, m.member_name " +
                     "FROM inquiry i " +
                     "JOIN member m ON i.member_id = m.member_id " +
                     "WHERE i.inq_status = '대기중' " +
                     "ORDER BY i.inq_create_at DESC " +
                     "LIMIT 1";
        try (Connection con = pool.getConnection();
             PreparedStatement pstmt = con.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
                bean = new InquiryBean();
                bean.setInq_id(rs.getInt("inq_id"));
                bean.setInq_type(rs.getString("inq_type"));
                bean.setMember_name(rs.getString("member_name"));
                bean.setInq_create_at(rs.getTimestamp("inq_create_at"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return bean;
    }
}
