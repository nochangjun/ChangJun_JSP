package project;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Vector;

public class InquiryMgr {

	private DBConnectionMgr pool;

	public InquiryMgr() {
		pool = DBConnectionMgr.getInstance();
	}
	
	//insert
    public void insertInquiry(InquiryBean bean) {
        Connection con = null;
        PreparedStatement pstmt = null;
        String sql = null;
        try {
            con = pool.getConnection();
            // 명시적으로 컬럼명을 지정하고 inq_create_at은 기본값 사용
            sql = "insert into inquiry (inq_type, inq_title, inq_content, inq_status, member_id) values (?,?,?,'대기중',?)";
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, bean.getInq_type());
            pstmt.setString(2, bean.getInq_title());
            pstmt.setString(3, bean.getInq_content());
            pstmt.setString(4, bean.getMember_id());
            pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt);
        }
    }
    
    //delete
    public void deleteInquiry(int inq_id) {
        Connection con = null;
        PreparedStatement pstmt = null;
        String sql = null;
        try {
            con = pool.getConnection();
            sql = "delete from inquiry where inq_id = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, inq_id);
            pstmt.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt);
        }
    }
	
	// 문의 상세 + 작성자 정보 가져오기
	public InquiryBean getInquiryWithMember(int inqId) {
	    Connection con = null;
	    PreparedStatement pstmt = null;
	    ResultSet rs = null;
	    InquiryBean bean = null; // 여기서 null로 시작해야 함

	    try {
	        con = pool.getConnection();
	        String sql = "SELECT i.*, m.member_name, m.member_email, m.member_phone " +
	                     "FROM inquiry i " +
	                     "JOIN member m ON i.member_id = m.member_id " +
	                     "WHERE i.inq_id = ?";
	        pstmt = con.prepareStatement(sql);
	        pstmt.setInt(1, inqId);
	        rs = pstmt.executeQuery();

	        if (rs.next()) {
	            bean = new InquiryBean(); // 조회된 경우에만 생성
	            bean.setInq_id(rs.getInt("inq_id"));
	            bean.setInq_type(rs.getString("inq_type"));
	            bean.setInq_title(rs.getString("inq_title"));
	            bean.setInq_content(rs.getString("inq_content"));
	            bean.setInq_create_at(rs.getTimestamp("inq_create_at"));
	            bean.setInq_status(rs.getString("inq_status"));
	            bean.setMember_id(rs.getString("member_id"));

	            bean.setMember_name(rs.getString("member_name"));
	            bean.setMember_email(rs.getString("member_email"));
	            bean.setMember_phone(rs.getString("member_phone"));
	        }
	    } catch (Exception e) {
	        e.printStackTrace();
	    } finally {
	        pool.freeConnection(con, pstmt, rs);
	    }
	    return bean;
	}
	
	public List<InquiryBean> getInquiryList(String status) {
	    Connection con = null;
	    PreparedStatement pstmt = null;
	    ResultSet rs = null;
	    List<InquiryBean> list = new ArrayList<>();

	    try {
	        con = pool.getConnection();
	        String sql = "SELECT i.*, m.member_name FROM inquiry i JOIN member m ON i.member_id = m.member_id ";
	        
	        if (status != null && !status.isEmpty()) {
	            sql += "WHERE i.inq_status = ? ";
	        }
	        
	        sql += "ORDER BY inq_id DESC";

	        pstmt = con.prepareStatement(sql);
	        
	        if (status != null && !status.isEmpty()) {
	            pstmt.setString(1, status);
	        }

	        rs = pstmt.executeQuery();

	        while (rs.next()) {
	            InquiryBean bean = new InquiryBean();
	            bean.setInq_id(rs.getInt("inq_id"));
	            bean.setInq_type(rs.getString("inq_type"));
	            bean.setInq_title(rs.getString("inq_title"));
	            bean.setInq_content(rs.getString("inq_content"));
	            bean.setInq_create_at(rs.getTimestamp("inq_create_at"));
	            bean.setInq_status(rs.getString("inq_status"));
	            bean.setMember_id(rs.getString("member_id"));
	            bean.setMember_name(rs.getString("member_name"));
	            list.add(bean);
	        }

	    } catch (Exception e) {
	        e.printStackTrace();
	    } finally {
	        pool.freeConnection(con, pstmt, rs);
	    }

	    return list;
	}

	public List<InquiryBean> getFilteredInquiryList(String status, String type, String keyword, int startRow, int pageSize, String sort, String order) {
	    Connection con = null;
	    PreparedStatement pstmt = null;
	    ResultSet rs = null;
	    List<InquiryBean> list = new ArrayList<>();

	    try {
	        con = pool.getConnection();
	        StringBuilder sql = new StringBuilder();
	        sql.append("SELECT i.*, m.member_name FROM inquiry i ");
	        sql.append("JOIN member m ON i.member_id = m.member_id WHERE 1=1 ");

	        if (status != null && !status.isEmpty()) {
	            sql.append("AND i.inq_status = ? ");
	        }
	        if (type != null && !type.isEmpty()) {
	            sql.append("AND i.inq_type = ? ");
	        }
	        if (keyword != null && !keyword.isEmpty()) {
	            sql.append("AND (i.inq_title LIKE ? OR m.member_name LIKE ?) ");
	        }

	        // 안전하게 컬럼명 필터링
	        List<String> allowedSorts = Arrays.asList("inq_id", "inq_create_at", "inq_status");
	        if (!allowedSorts.contains(sort)) sort = "inq_id";
	        if (!order.equalsIgnoreCase("asc") && !order.equalsIgnoreCase("desc")) order = "desc";

	        sql.append("ORDER BY i.").append(sort).append(" ").append(order.toUpperCase()).append(" LIMIT ?, ?");

	        pstmt = con.prepareStatement(sql.toString());

	        int idx = 1;
	        if (status != null && !status.isEmpty()) pstmt.setString(idx++, status);
	        if (type != null && !type.isEmpty()) pstmt.setString(idx++, type);
	        if (keyword != null && !keyword.isEmpty()) {
	            pstmt.setString(idx++, "%" + keyword + "%");
	            pstmt.setString(idx++, "%" + keyword + "%");
	        }
	        pstmt.setInt(idx++, startRow);
	        pstmt.setInt(idx, pageSize);

	        rs = pstmt.executeQuery();
	        while (rs.next()) {
	            InquiryBean bean = new InquiryBean();
	            bean.setInq_id(rs.getInt("inq_id"));
	            bean.setInq_type(rs.getString("inq_type"));
	            bean.setInq_title(rs.getString("inq_title"));
	            bean.setInq_content(rs.getString("inq_content"));
	            bean.setInq_create_at(rs.getTimestamp("inq_create_at"));
	            bean.setInq_status(rs.getString("inq_status"));
	            bean.setMember_id(rs.getString("member_id"));
	            bean.setMember_name(rs.getString("member_name"));
	            list.add(bean);
	        }

	    } catch (Exception e) {
	        e.printStackTrace();
	    } finally {
	        pool.freeConnection(con, pstmt, rs);
	    }

	    return list;
	}

	//inquiry board
    public List<InquiryBean> getFilteredInquiryList2(String status, String type, String keyword, int startRow, int pageSize, String sort, String order) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<InquiryBean> list = new ArrayList<>();

        try {
            con = pool.getConnection();
            StringBuilder sql = new StringBuilder();
            sql.append("SELECT i.*, m.member_nickname FROM inquiry i ");
            sql.append("JOIN member m ON i.member_id = m.member_id WHERE 1=1 ");

            if (status != null && !status.isEmpty()) {
                sql.append("AND i.inq_status = ? ");
            }
            if (type != null && !type.isEmpty()) {
                sql.append("AND i.inq_type = ? ");
            }
            if (keyword != null && !keyword.isEmpty()) {
                sql.append("AND (i.inq_title LIKE ? OR m.member_nickname LIKE ?) ");
            }

            // 안전하게 컬럼명 필터링
            List<String> allowedSorts = Arrays.asList("inq_id", "inq_create_at", "inq_status");
            if (!allowedSorts.contains(sort)) sort = "inq_id";
            if (!order.equalsIgnoreCase("asc") && !order.equalsIgnoreCase("desc")) order = "desc";

            sql.append("ORDER BY i.").append(sort).append(" ").append(order.toUpperCase()).append(" LIMIT ?, ?");

            pstmt = con.prepareStatement(sql.toString());

            int idx = 1;
            if (status != null && !status.isEmpty()) pstmt.setString(idx++, status);
            if (type != null && !type.isEmpty()) pstmt.setString(idx++, type);
            if (keyword != null && !keyword.isEmpty()) {
                pstmt.setString(idx++, "%" + keyword + "%");
                pstmt.setString(idx++, "%" + keyword + "%");
            }
            pstmt.setInt(idx++, startRow);
            pstmt.setInt(idx, pageSize);

            rs = pstmt.executeQuery();
            while (rs.next()) {
                InquiryBean bean = new InquiryBean();
                bean.setInq_id(rs.getInt("inq_id"));
                bean.setInq_type(rs.getString("inq_type"));
                bean.setInq_title(rs.getString("inq_title"));
                bean.setInq_content(rs.getString("inq_content"));
                bean.setInq_create_at(rs.getTimestamp("inq_create_at"));
                bean.setInq_status(rs.getString("inq_status"));
                bean.setMember_id(rs.getString("member_id"));
                bean.setMember_nickname(rs.getString("member_nickname"));
                list.add(bean);
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt, rs);
        }

        return list;
    }

	public int getFilteredInquiryCount(String status, String type, String keyword) {
	    Connection con = null;
	    PreparedStatement pstmt = null;
	    ResultSet rs = null;
	    int count = 0;

	    try {
	        con = pool.getConnection();
	        StringBuilder sql = new StringBuilder();
	        sql.append("SELECT COUNT(*) FROM inquiry i ");
	        sql.append("JOIN member m ON i.member_id = m.member_id ");
	        sql.append("WHERE 1=1 ");

	        if (status != null && !status.isEmpty()) {
	            sql.append("AND i.inq_status = ? ");
	        }
	        if (type != null && !type.isEmpty()) {
	            sql.append("AND i.inq_type = ? ");
	        }
	        if (keyword != null && !keyword.isEmpty()) {
	            sql.append("AND (i.inq_title LIKE ? OR m.member_name LIKE ?) ");
	        }

	        pstmt = con.prepareStatement(sql.toString());

	        int idx = 1;
	        if (status != null && !status.isEmpty()) pstmt.setString(idx++, status);
	        if (type != null && !type.isEmpty()) pstmt.setString(idx++, type);
	        if (keyword != null && !keyword.isEmpty()) {
	            pstmt.setString(idx++, "%" + keyword + "%");
	            pstmt.setString(idx++, "%" + keyword + "%");
	        }

	        rs = pstmt.executeQuery();
	        if (rs.next()) {
	            count = rs.getInt(1);
	        }

	    } catch (Exception e) {
	        e.printStackTrace();
	    } finally {
	        pool.freeConnection(con, pstmt, rs);
	    }

	    return count;
	}

	public void updateInquiryStatus(int inqId, String status) {
	    Connection con = null;
	    PreparedStatement pstmt = null;
	    try {
	        con = pool.getConnection();
	        String sql = "UPDATE inquiry SET inq_status = ? WHERE inq_id = ?";
	        pstmt = con.prepareStatement(sql);
	        pstmt.setString(1, status);
	        pstmt.setInt(2, inqId);
	        pstmt.executeUpdate();
	    } catch (Exception e) {
	        e.printStackTrace();
	    } finally {
	        pool.freeConnection(con, pstmt);
	    }
	}

	// 답변 등록 (inq_comment 테이블에 insert + inquiry 상태 완료로 변경)
	public void addInquiryReply(int inqId, String replyContent, String adminId) {
	    Connection con = null;
	    PreparedStatement pstmt = null;
	    ResultSet rs = null;
	    
	    try {
	        con = pool.getConnection();

	        // 댓글 저장
	        String insertSql = "INSERT INTO inq_comment (inq_content, inq_comment_at, member_id, inq_id) VALUES (?, now(), ?, ?)";
	        pstmt = con.prepareStatement(insertSql);
	        pstmt.setString(1, replyContent);
	        pstmt.setString(2, adminId);
	        pstmt.setInt(3, inqId);
	        pstmt.executeUpdate();
	        pstmt.close();

	        // 상태 변경
	        String updateSql = "UPDATE inquiry SET inq_status = '완료' WHERE inq_id = ?";
	        pstmt = con.prepareStatement(updateSql);
	        pstmt.setInt(1, inqId);
	        pstmt.executeUpdate();
	        pstmt.close();
	        
	        // 문의 작성자의 member_id 가져오기
	        String selectSql = "SELECT member_id FROM inquiry WHERE inq_id = ?";
	        pstmt = con.prepareStatement(selectSql);
	        pstmt.setInt(1, inqId);
	        rs = pstmt.executeQuery();
	        
	        if (rs.next()) {
	            String memberId = rs.getString("member_id");

	            // 4. 알림 생성 (inq_id만 저장, is_read는 기본 0)
	            String noticeSql = "INSERT INTO notice (inq_id, is_read, member_id) VALUES (?, 0, ?)";
	            pstmt = con.prepareStatement(noticeSql);
	            pstmt.setInt(1, inqId);
	            pstmt.setString(2, memberId);
	            pstmt.executeUpdate();
	        }
	        
	    } catch (Exception e) {
	        e.printStackTrace();
	    } finally {
	        pool.freeConnection(con, pstmt, rs);
	    }
	}

	public InqCommentBean getCommentByInquiryId(int inquiryId) {
	    InqCommentBean bean = null;
	    Connection conn = null;
	    PreparedStatement pstmt = null;
	    ResultSet rs = null;
	    String sql = "SELECT * FROM inq_comment WHERE inq_id = ?";
	    try {
	        conn = DBConnectionMgr.getInstance().getConnection();
	        pstmt = conn.prepareStatement(sql);
	        pstmt.setInt(1, inquiryId);
	        rs = pstmt.executeQuery();
	        if (rs.next()) {
	            bean = new InqCommentBean();
	            bean.setInq_comment_id(rs.getInt("inq_comment_id"));
	            bean.setInq_content(rs.getString("inq_content"));
	            bean.setInq_comment_at(rs.getTimestamp("inq_comment_at"));
	            bean.setMember_id(rs.getString("member_id"));
	            bean.setInq_id(rs.getInt("inq_id"));
	        }
	    } catch (Exception e) {
	        e.printStackTrace();
	    } finally {
	        DBConnectionMgr.getInstance().freeConnection(conn, pstmt, rs);
	    }
	    return bean;
	}

	public Vector<InquiryBean> getInquiriesByMember(String memberId, int start, int pageSize) {
	    Vector<InquiryBean> vlist = new Vector<>();
	    Connection conn = null;
	    PreparedStatement pstmt = null;
	    ResultSet rs = null;

	    String sql = "SELECT * FROM inquiry WHERE member_id = ? ORDER BY inq_create_at DESC";

	    try {
	        conn = pool.getConnection();
	        pstmt = conn.prepareStatement(sql);
	        pstmt.setString(1, memberId);
	        rs = pstmt.executeQuery();

	        while (rs.next()) {
	            InquiryBean bean = new InquiryBean();
	            bean.setInq_id(rs.getInt("inq_id"));
	            bean.setInq_title(rs.getString("inq_title"));
	            bean.setInq_create_at(rs.getTimestamp("inq_create_at"));
	            bean.setInq_status(rs.getString("inq_status"));
	            bean.setMember_id(rs.getString("member_id"));
	            // 필요한 경우 닉네임 조회해서 세팅
	            vlist.add(bean);
	        }
	    } catch (Exception e) {
	        e.printStackTrace();
	    } finally {
	        pool.freeConnection(conn, pstmt, rs);
	    }

	    return vlist;
	}
	
	public int getInquiryCountByMember(String member_id) {
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String sql = null;
		int cnt=0;
		try {
			con = pool.getConnection();
			sql = "select count(*) from inquiry where member_id = ?";
			pstmt = con.prepareStatement(sql);
			pstmt.setString(1, member_id);
			rs = pstmt.executeQuery();
			if (rs.next()) {
				cnt = rs.getInt(1);
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pool.freeConnection(con, pstmt, rs);
		}
		return cnt;
	}
}
