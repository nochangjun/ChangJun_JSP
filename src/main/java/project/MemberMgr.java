package project;

import java.sql.*;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.*;
import java.sql.Date;  // Use java.sql.Date

public class MemberMgr {

	private DBConnectionMgr pool;

	public MemberMgr() {
		pool = DBConnectionMgr.getInstance();
	}

	// 로그인 : 성공 -> true
	public boolean loginMember(String id, String pwd) {
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String sql = null;
		boolean flag = false;
		try {
			con = pool.getConnection();
			sql = "select member_id from member where member_id = ? and member_pwd = ?";
			pstmt = con.prepareStatement(sql);
			pstmt.setString(1, id);
			pstmt.setString(2, pwd);
			rs = pstmt.executeQuery();
			flag = rs.next();//결과 있으면 true, 없으면 false
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pool.freeConnection(con, pstmt, rs);
		}
		return flag;
	}
	
	// 관리자 로그인 : 성공 -> true
	public boolean loginAdmin(String id, String pwd) {
		Connection con = null;
	    PreparedStatement pstmt = null;
	    ResultSet rs = null;
	    boolean flag = false;
	    String sql = "SELECT admin_id FROM admin WHERE admin_id = ? AND admin_pwd = ?";
	    try {
	        con = pool.getConnection();
	        pstmt = con.prepareStatement(sql);
	        pstmt.setString(1, id);
	        pstmt.setString(2, pwd);
	        rs = pstmt.executeQuery();
	        flag = rs.next();  // 결과가 있으면 로그인 성공
	    } catch (Exception e) {
	        e.printStackTrace();
	    } finally {
	        pool.freeConnection(con, pstmt, rs);
	    }
	    return flag;
	}
	
	//id 중복체크 : 중복 -> true --db1
	public boolean checkId(String id) {
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String sql = null;
		boolean flag = false;
		try {
			con = pool.getConnection();
			sql = "select member_id from member where member_id = ?";
			pstmt = con.prepareStatement(sql);
			pstmt.setString(1, id);
			rs = pstmt.executeQuery();
			flag = rs.next();	//결과값이 있으면 true
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pool.freeConnection(con, pstmt, rs);
		}
		return flag;
	}
	
	// 닉네임 중복 체크 : 중복 -> true
    public boolean checkNickname(String nickname) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        boolean flag = false;
        String sql = null;
        try {
            con = pool.getConnection();
            sql = "SELECT member_nickname FROM member WHERE member_nickname = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, nickname);
            rs = pstmt.executeQuery();
            flag = rs.next(); // 결과값이 있으면 true
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt, rs);
        }
        return flag;
    }
    // 휴대폰 중복 체크 : 중복 -> true
    public boolean checkPhone(String phone) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        boolean flag = false;
        String sql = "SELECT member_phone FROM member WHERE member_phone = ?";
        try {
            con = pool.getConnection();
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, phone);
            rs = pstmt.executeQuery();
            flag = rs.next(); // 결과값이 있으면 true
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt, rs);
        }
        return flag;
    }
    
    // 이메일 중복 체크 : 중복 -> true
    public boolean checkEmail(String email) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        boolean flag = false;
        String sql = "SELECT member_email FROM member WHERE member_email = ?";
        try {
            con = pool.getConnection();
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, email);
            rs = pstmt.executeQuery();
            flag = rs.next(); // 결과값이 있으면 true
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt, rs);
        }
        return flag;
    }
	
	//회원가입
	public boolean insertMember(MemberBean bean) {
		Connection con = null;
		PreparedStatement pstmt = null;
		String sql = null;
		boolean flag = false;
		try {
			con = pool.getConnection();
			sql = "INSERT INTO member (member_id, member_pwd, member_name, member_phone, member_email, member_nickname, member_image, member_create_at, member_role, ban_post_until, ban_comment_until, ban_review_until) " +
				      "VALUES (?, ?, ?, ?, ?, ?, ?, now(), ?, NULL, NULL, NULL)";
			pstmt = con.prepareStatement(sql);
			pstmt.setString(1, bean.getMember_id());	
			pstmt.setString(2, bean.getMember_pwd());	
			pstmt.setString(3, bean.getMember_name());	
			pstmt.setString(4, bean.getMember_phone());	
			pstmt.setString(5, bean.getMember_email());	
			pstmt.setString(6, bean.getMember_nickname());
			pstmt.setString(7, bean.getMember_image());
			
	        String role = bean.getMember_role();
	        if (role == null || role.trim().isEmpty()) {
	            role = "일반회원";
	        }
	        pstmt.setString(8, role);
	        
			int cnt = pstmt.executeUpdate();
	        if(cnt > 0) {
	            flag = true;
	        }
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pool.freeConnection(con, pstmt);
		}
		return flag;
	}
	
	//회원정보 가져오기
	public MemberBean getMember(String id) {
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String sql = null;
		MemberBean bean = new MemberBean();
		try {
			con = pool.getConnection();
			sql = "select * from member where member_id = ?";
			pstmt = con.prepareStatement(sql);
			pstmt.setString(1, id);
			rs = pstmt.executeQuery();
			if(rs.next()) {
				bean.setMember_id(rs.getString("member_id"));
				bean.setMember_pwd(rs.getString("member_pwd"));
				bean.setMember_name(rs.getString("member_name"));
				bean.setMember_phone(rs.getString("member_phone"));
				bean.setMember_email(rs.getString("member_email"));
				bean.setMember_nickname(rs.getString("member_nickname"));
				bean.setMember_image(rs.getString("member_image"));
				bean.setMember_create_at(rs.getString("member_create_at"));
				bean.setMember_role(rs.getString("member_role"));
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pool.freeConnection(con, pstmt, rs);
		}
		return bean;
	}
	
	//회원정보 가져오기
		public Vector<MemberBean> getAllMembers() {
			Vector<MemberBean> vlist = new Vector<>();
			Connection con = null;
			PreparedStatement pstmt = null;
			ResultSet rs = null;
			try {
				DBConnectionMgr pool = DBConnectionMgr.getInstance();
				con = pool.getConnection();

				String sql = "SELECT m.*, " +
				             "(SELECT COUNT(*) FROM review r WHERE r.member_id = m.member_id) AS review_count " +
				             "FROM member m";
				pstmt = con.prepareStatement(sql);
				rs = pstmt.executeQuery();

				while (rs.next()) {
					MemberBean bean = new MemberBean();
					bean.setMember_id(rs.getString("member_id"));
					bean.setMember_name(rs.getString("member_name"));
					bean.setMember_email(rs.getString("member_email"));
					bean.setMember_create_at(rs.getString("member_create_at"));
					bean.setMember_role(rs.getString("member_role"));
					bean.setReview_count(rs.getInt("review_count")); // 전체 리뷰 수 포함
					vlist.add(bean);
				}

			} catch (Exception e) {
				e.printStackTrace();
			} finally {
				pool.freeConnection(con, pstmt, rs);
			}
			return vlist;
		}

	//회원 수정
	public boolean updateMemberProfile(String id, String nickname, String phone, String email, String imageFilename) {
	    Connection con = null;
	    PreparedStatement pstmt = null;
	    String sql = "UPDATE member SET member_nickname = ?, member_phone = ?, member_email = ?, member_image = ? WHERE member_id = ?";
	    boolean result = false;
	    try {
	        con = pool.getConnection();
	        pstmt = con.prepareStatement(sql);
	        pstmt.setString(1, nickname);
	        pstmt.setString(2, phone);
	        pstmt.setString(3, email);
	        pstmt.setString(4, imageFilename);
	        pstmt.setString(5, id);
	        result = pstmt.executeUpdate() == 1;
	    } catch (Exception e) {
	        e.printStackTrace();
	    } finally {
	        pool.freeConnection(con, pstmt);
	    }
	    return result;
	}


	//회원 삭제
	public void deleteMembers(String[] memberIds) {
	    Connection con = null;
	    PreparedStatement pstmt = null;
	    try {
	    	con = pool.getConnection();
	        String sql = "DELETE FROM member WHERE member_id = ?";
	        pstmt = con.prepareStatement(sql);
	        for (String id : memberIds) {
	            pstmt.setString(1, id);
	            pstmt.executeUpdate();
	        }
	    } catch (Exception e) {
	        e.printStackTrace();
	    } finally {
	        pool.freeConnection(con, pstmt);
	    }
	}
	
	// 현재 비밀번호 일치 여부 확인
	public boolean checkPassword(String id, String inputPw) {
	    Connection con = null;
	    PreparedStatement pstmt = null;
	    ResultSet rs = null;
	    boolean isValid = false;
	    try {
	        con = pool.getConnection();
	        String sql = "SELECT member_pwd FROM member WHERE member_id = ?";
	        pstmt = con.prepareStatement(sql);
	        pstmt.setString(1, id);
	        rs = pstmt.executeQuery();
	        if (rs.next() && rs.getString("member_pwd").equals(inputPw)) {
	            isValid = true;
	        }
	    } catch (Exception e) {
	        e.printStackTrace();
	    } finally {
	        pool.freeConnection(con, pstmt, rs);
	    }
	    return isValid;
	}

	// 비밀번호 업데이트
	public boolean updatePassword(String id, String newPw) {
	    Connection con = null;
	    PreparedStatement pstmt = null;
	    boolean result = false;
	    try {
	        con = pool.getConnection();
	        String sql = "UPDATE member SET member_pwd = ? WHERE member_id = ?";
	        pstmt = con.prepareStatement(sql);
	        pstmt.setString(1, newPw);
	        pstmt.setString(2, id);
	        result = pstmt.executeUpdate() == 1;
	    } catch (Exception e) {
	        e.printStackTrace();
	    } finally {
	        pool.freeConnection(con, pstmt);
	    }
	    return result;
	}
	
	public Vector<MemberBean> getMembersByReviewPeriod(String start, String end) {
	    Vector<MemberBean> vlist = new Vector<>();
	    Connection con = null;
	    PreparedStatement pstmt = null;
	    ResultSet rs = null;
	    try {
	    	con = DBConnectionMgr.getInstance().getConnection();
	        String sql = "SELECT m.*, COUNT(r.review_id) AS review_count " +
	                     "FROM member m " +
	                     "JOIN review r ON m.member_id = r.member_id " +
	                     "WHERE r.review_create_at BETWEEN ? AND ? " +
	                     "GROUP BY m.member_id";
	        pstmt = con.prepareStatement(sql);
	        pstmt.setString(1, start + " 00:00:00");
	        pstmt.setString(2, end + " 23:59:59");
	        rs = pstmt.executeQuery();
	        while (rs.next()) {
	            MemberBean bean = new MemberBean();
	            bean.setMember_id(rs.getString("member_id"));
	            bean.setMember_name(rs.getString("member_name"));
	            bean.setMember_email(rs.getString("member_email"));
	            bean.setMember_create_at(rs.getString("member_create_at"));
	            bean.setMember_role(rs.getString("member_role"));
	            bean.setReview_count(rs.getInt("review_count"));
	            vlist.add(bean);
	        }
	    } catch (Exception e) {
	        e.printStackTrace();
	    } finally {
	        pool.freeConnection(con, pstmt, rs);
	    }
	    return vlist;
	}

	public Vector<MemberBean> getMembersBySignupPeriod(String start, String end) {
	    Vector<MemberBean> vlist = new Vector<>();
	    Connection con = null;
	    PreparedStatement pstmt = null;
	    ResultSet rs = null;
	    try {
	        DBConnectionMgr pool = DBConnectionMgr.getInstance();
	        con = pool.getConnection();

	        String sql = "SELECT * FROM member WHERE member_create_at BETWEEN ? AND ?";
	        pstmt = con.prepareStatement(sql);
	        pstmt.setString(1, start + " 00:00:00");
	        pstmt.setString(2, end + " 23:59:59");

	        rs = pstmt.executeQuery();
	        while (rs.next()) {
	            MemberBean bean = new MemberBean();
	            bean.setMember_id(rs.getString("member_id"));
	            bean.setMember_name(rs.getString("member_name"));
	            bean.setMember_email(rs.getString("member_email"));
	            bean.setMember_create_at(rs.getString("member_create_at"));
	            bean.setMember_role(rs.getString("member_role"));
	            bean.setReview_count(0); // 기본값 0 (리뷰 수 안 셈)
	            vlist.add(bean);
	        }

	    } catch (Exception e) {
	        e.printStackTrace();
	    } finally {
	        DBConnectionMgr.getInstance().freeConnection(con, pstmt, rs);
	    }
	    return vlist;
	}
	
	// 이메일로 회원 조회(네이버 로그인 회원의 경우 필요)
	public MemberBean getMemberByEmail(String email) {
	    Connection con = null;
	    PreparedStatement pstmt = null;
	    ResultSet rs = null;
	    MemberBean bean = null;
	    try {
	        con = pool.getConnection();
	        String sql = "select * from member where member_email = ?";
	        pstmt = con.prepareStatement(sql);
	        pstmt.setString(1, email);
	        rs = pstmt.executeQuery();
	        if (rs.next()) {
	            bean = new MemberBean();
	            bean.setMember_id(rs.getString("member_id"));
	            bean.setMember_name(rs.getString("member_name"));
				bean.setMember_phone(rs.getString("member_phone"));
	            bean.setMember_email(rs.getString("member_email"));
	            bean.setMember_nickname(rs.getString("member_nickname"));
	            bean.setMember_image(rs.getString("member_image"));
	            bean.setMember_create_at(rs.getString("member_create_at"));
	        }
	    } catch (Exception e) {
	        e.printStackTrace();
	    } finally {
	        pool.freeConnection(con, pstmt, rs);
	    }
	    return bean;
	}
	
	// 관리자 정보 조회: 아이디로 관리자 정보를 가져옴
	public AdminBean getAdmin(String id) {
	    Connection con = null;
	    PreparedStatement pstmt = null;
	    ResultSet rs = null;
	    AdminBean bean = null;
	    String sql = "SELECT * FROM admin WHERE admin_id = ?";
	    try {
	        con = pool.getConnection();
	        pstmt = con.prepareStatement(sql);
	        pstmt.setString(1, id);
	        rs = pstmt.executeQuery();
	        if (rs.next()) {
	            bean = new AdminBean();
	            bean.setAdmin_id(rs.getString("admin_id"));
	            bean.setAdmin_pwd(rs.getString("admin_pwd"));
	            bean.setAdmin_nickname(rs.getString("admin_nickname"));
	            bean.setAdmin_phone(rs.getString("admin_phone"));
	            bean.setAdmin_email(rs.getString("admin_email"));
	            bean.setAdmin_image(rs.getString("admin_image"));
	        }
	    } catch (Exception e) {
	        e.printStackTrace();
	    } finally {
	        pool.freeConnection(con, pstmt, rs);
	    }
	    return bean;
	}
	
	// 관리자 이메일로 회원 조회
	public AdminBean getAdminByEmail(String email) {
	    Connection con = null;
	    PreparedStatement pstmt = null;
	    ResultSet rs = null;
	    AdminBean bean = null;
	    String sql = "SELECT * FROM admin WHERE admin_email = ?";
	    try {
	        con = pool.getConnection();
	        pstmt = con.prepareStatement(sql);
	        pstmt.setString(1, email);
	        rs = pstmt.executeQuery();
	        if (rs.next()) {
	            bean = new AdminBean();
	            bean.setAdmin_id(rs.getString("admin_id"));
	            bean.setAdmin_pwd(rs.getString("admin_pwd"));
	            bean.setAdmin_nickname(rs.getString("admin_nickname"));
	            bean.setAdmin_phone(rs.getString("admin_phone"));
	            bean.setAdmin_email(rs.getString("admin_email"));
	            bean.setAdmin_image(rs.getString("admin_image"));
	        }
	    } catch (Exception e) {
	        e.printStackTrace();
	    } finally {
	        pool.freeConnection(con, pstmt, rs);
	    }
	    return bean;
	}
	
	public boolean imposeBanOnUser(String memberId) {
	    Connection con = null;
	    PreparedStatement pstmt = null;
	    boolean result = false;

	    try {
	        con = pool.getConnection();

	        // 현재 시각 기준으로 3일 후를 계산
	        Calendar cal = Calendar.getInstance();
	        cal.add(Calendar.DATE, 3);  // 3일간 금지
	        Timestamp banUntil = new Timestamp(cal.getTimeInMillis());

	        // 게시글, 댓글, 대댓글, 리뷰 금지 설정
	        String sql = "UPDATE member SET ban_post_until = ?, ban_comment_until = ?, ban_review_until = ? WHERE member_id = ?";
	        pstmt = con.prepareStatement(sql);
	        pstmt.setTimestamp(1, banUntil);  // 게시글 금지
	        pstmt.setTimestamp(2, banUntil);  // 댓글 금지
	        pstmt.setTimestamp(3, banUntil);  // 리뷰 금지
	        pstmt.setString(4, memberId);

	        int count = pstmt.executeUpdate();
	        result = (count > 0);
	    } catch (Exception e) {
	        e.printStackTrace();
	    } finally {
	        pool.freeConnection(con, pstmt);
	    }

	    return result;
	}

	
	public boolean canPost(String memberId) {
	    Connection con = null;
	    PreparedStatement pstmt = null;
	    ResultSet rs = null;

	    try {
	        con = pool.getConnection();

	        String sql = "SELECT ban_post_until FROM member WHERE member_id = ?";
	        pstmt = con.prepareStatement(sql);
	        pstmt.setString(1, memberId);

	        rs = pstmt.executeQuery();

	        if (rs.next()) {
	            Timestamp banPostUntil = rs.getTimestamp("ban_post_until");
	            // 만약 현재 시간이 ban_post_until 이후라면 작성 가능
	            if (banPostUntil != null && banPostUntil.after(new Timestamp(System.currentTimeMillis()))) {
	                return false; // 제한이 걸려 있으면 게시글 작성 불가능
	            }
	        }
	    } catch (Exception e) {
	        e.printStackTrace();
	    } finally {
	        pool.freeConnection(con, pstmt, rs);
	    }
	    return true; // 제한이 없으면 작성 가능
	}


	
	public boolean canComment(String memberId) {
	    Connection con = null;
	    PreparedStatement pstmt = null;
	    ResultSet rs = null;

	    try {
	        con = pool.getConnection();

	        String sql = "SELECT ban_comment_until FROM member WHERE member_id = ?";
	        pstmt = con.prepareStatement(sql);
	        pstmt.setString(1, memberId);

	        rs = pstmt.executeQuery();

	        if (rs.next()) {
	            Timestamp banCommentUntil = rs.getTimestamp("ban_comment_until");
	            // 만약 현재 시간이 ban_comment_until 이후라면 댓글 작성 가능
	            if (banCommentUntil != null && banCommentUntil.after(new Timestamp(System.currentTimeMillis()))) {
	                return false; // 제한이 걸려 있으면 댓글 작성 불가능
	            }
	        }
	    } catch (Exception e) {
	        e.printStackTrace();
	    } finally {
	        pool.freeConnection(con, pstmt, rs);
	    }
	    return true; // 제한이 없으면 댓글 작성 가능
	}


	public boolean canReview(String memberId) {
	    Connection con = null;
	    PreparedStatement pstmt = null;
	    ResultSet rs = null;
	    boolean canReview = true;

	    try {
	        con = pool.getConnection();
	        String sql = "SELECT ban_review_until FROM member WHERE member_id = ?";
	        pstmt = con.prepareStatement(sql);
	        pstmt.setString(1, memberId);
	        rs = pstmt.executeQuery();

	        if (rs.next()) {
	            Timestamp banUntil = rs.getTimestamp("ban_review_until");
	            if (banUntil != null && banUntil.after(new Timestamp(System.currentTimeMillis()))) {
	                canReview = false;  // 금지 기간이 남아 있으면 리뷰 작성 불가
	            }
	        }
	    } catch (Exception e) {
	        e.printStackTrace();
	        canReview = true;
	    } finally {
	        pool.freeConnection(con, pstmt, rs);
	    }

	    return canReview;
	}
	
	
	public void applyPostRestriction(String memberId) {
        Connection con = null;
        PreparedStatement pstmt = null;

        try {
            con = pool.getConnection();
            // 3일간 제한
            Calendar cal = Calendar.getInstance();
            cal.add(Calendar.DATE, 3); // 3일 후
            Timestamp restrictionEnd = new Timestamp(cal.getTimeInMillis());

            String sql = "UPDATE member SET ban_post_until = ? WHERE member_id = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setTimestamp(1, restrictionEnd);
            pstmt.setString(2, memberId);
            pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt);
        }
    }

	// 신고된 사용자에게 작성 제한을 3일로 설정
	public void applyRestrictions(String reportedMemberId) {
        Connection con = null;
        PreparedStatement pstmt = null;

        try {
            con = pool.getConnection();

            // 3일 후 시간을 계산
            Calendar cal = Calendar.getInstance();
            cal.add(Calendar.DATE, 3); // 3일 후
            Timestamp restrictionEnd = new Timestamp(cal.getTimeInMillis());

            // 게시글 작성 제한 설정
            String sql = "UPDATE member SET ban_post_until = ?, ban_comment_until = ?, ban_review_until = ? WHERE member_id = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setTimestamp(1, restrictionEnd); // 3일 후로 설정
            pstmt.setTimestamp(2, restrictionEnd); // 3일 후로 설정
            pstmt.setTimestamp(3, restrictionEnd); // 3일 후로 설정
            pstmt.setString(4, reportedMemberId);  // 신고된 사용자의 ID
            pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt);
        }
    }
	
	 // 사용자가 리뷰 작성이 제한된 상태인지 확인하는 메서드
    public boolean isBannedFromReview(String memberId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        boolean isBanned = false;

        try {
            conn = pool.getConnection();
            String sql = "SELECT ban_review_until FROM member WHERE member_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, memberId);
            rs = pstmt.executeQuery();

            // 사용자의 제한 날짜 확인
            if (rs.next()) {
                Date banReviewUntil = rs.getDate("ban_review_until");
                // 제한 날짜가 있으면, 현재 날짜가 그 제한 날짜 이전이면 제한 중
                if (banReviewUntil != null && banReviewUntil.after(new java.util.Date())) {
                    isBanned = true;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, pstmt, rs);
        }

        return isBanned;
    }
    
    public boolean canPerformActions(String memberId) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        boolean canPerform = true;
        
        try {
            con = pool.getConnection();
            String sql = "SELECT ban_post_until, ban_comment_until, ban_review_until FROM member WHERE member_id = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, memberId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                Timestamp banPostUntil = rs.getTimestamp("ban_post_until");
                Timestamp banCommentUntil = rs.getTimestamp("ban_comment_until");
                Timestamp banReviewUntil = rs.getTimestamp("ban_review_until");
                Timestamp now = new Timestamp(System.currentTimeMillis());
                
                // 제한 시간이 현재보다 미래이면 제한 상태로 판단하여 false 반환
                if ((banPostUntil != null && banPostUntil.after(now)) ||
                    (banCommentUntil != null && banCommentUntil.after(now)) ||
                    (banReviewUntil != null && banReviewUntil.after(now))) {
                    canPerform = false;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt, rs);
        }
        
        return canPerform;
    }

    //네이버 메일로 비밀번호 찾기를 했을 때 임의로 쏴주는거
    public void updateMemberPassword(String memberId, String newPwd) {
        Connection con = null;
        PreparedStatement pstmt = null;
        try {
            con = pool.getConnection();
            String sql = "UPDATE member SET member_pwd = ? WHERE member_id = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, newPwd); // 암호화 없이 저장하는 경우 (※ 실제 서비스는 암호화 추천)
            pstmt.setString(2, memberId);
            pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt);
        }
    }

}

























