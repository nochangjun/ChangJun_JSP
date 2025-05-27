package project;

import java.sql.*;
import java.util.Vector;

public class EvtParticipantsMgr {

    private DBConnectionMgr pool;

    public EvtParticipantsMgr() {
        pool = DBConnectionMgr.getInstance();
    }

    public boolean insertWinner(EvtParticipantsBean bean) {
        Connection con = null;
        PreparedStatement pstmt = null;
        boolean success = false;

        try {
            con = pool.getConnection();
            String sql = "INSERT INTO evt_participants (evt_title, evt_content, admin_id) VALUES (?, ?, ?)";
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, bean.getEvt_title());
            pstmt.setString(2, bean.getEvt_content());
            pstmt.setString(3, bean.getAdmin_id());

            success = pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt);
        }
        return success;
    }

    public Vector<EvtParticipantsBean> getAllWinners() {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Vector<EvtParticipantsBean> list = new Vector<>();

        try {
            con = pool.getConnection();
            String sql = "SELECT * FROM evt_participants ORDER BY evt_created_at DESC";
            pstmt = con.prepareStatement(sql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                EvtParticipantsBean bean = new EvtParticipantsBean();
                bean.setEvt_id(rs.getInt("evt_id"));
                bean.setEvt_title(rs.getString("evt_title"));
                bean.setEvt_content(rs.getString("evt_content"));
                bean.setEvt_created_at(rs.getString("evt_created_at"));
                bean.setAdmin_id(rs.getString("admin_id"));
                list.add(bean);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt, rs);
        }

        return list;
    }
    
    public Vector<EvtParticipantsBean> getAllParticipants() {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT * FROM evt_participants ORDER BY evt_created_at DESC";
        Vector<EvtParticipantsBean> list = new Vector<>();

        try {
            con = pool.getConnection();
            pstmt = con.prepareStatement(sql);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                EvtParticipantsBean bean = new EvtParticipantsBean();
                bean.setEvt_id(rs.getInt("evt_id"));
                bean.setEvt_title(rs.getString("evt_title"));
                bean.setEvt_content(rs.getString("evt_content"));
                bean.setEvt_created_at(rs.getString("evt_created_at"));
                bean.setAdmin_id(rs.getString("admin_id"));
                list.add(bean);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt, rs);
        }

        return list;
    }

    
    public EvtParticipantsBean getEventById(int id) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT * FROM evt_participants WHERE evt_id = ?";
        EvtParticipantsBean bean = null;
        try {
            con = pool.getConnection();
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, id);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                bean = new EvtParticipantsBean();
                bean.setEvt_id(rs.getInt("evt_id"));
                bean.setEvt_title(rs.getString("evt_title"));
                bean.setEvt_content(rs.getString("evt_content"));
                bean.setEvt_created_at(rs.getString("evt_created_at"));
                bean.setAdmin_id(rs.getString("admin_id"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt, rs);
        }
        return bean;
    }

	// 당첨자 발표 삭제
	public boolean deleteWinner(int evtId) {
	    Connection con = null;
	    PreparedStatement pstmt = null;
	    boolean success = false;
	    String sql = "DELETE FROM evt_participants WHERE evt_id = ?";

	    try {
	        con = pool.getConnection();
	        pstmt = con.prepareStatement(sql);
	        pstmt.setInt(1, evtId);
	        success = pstmt.executeUpdate() > 0;
	    } catch (Exception e) {
	        e.printStackTrace();
	    } finally {
	        pool.freeConnection(con, pstmt);
	    }

	    return success;
	}
}
