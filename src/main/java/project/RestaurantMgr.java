package project;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Vector;

public class RestaurantMgr {
	private DBConnectionMgr pool;

	public RestaurantMgr() {
		pool = DBConnectionMgr.getInstance();
	}

	// 1. 식당 등록 (기본 상태는 '대기')
	public void insertRestaurant(RestaurantBean bean) {
		Connection con = null;
		PreparedStatement pstmt = null;
		String sql = "INSERT INTO restaurant (rst_status, rst_name, rst_introduction, rst_address, rst_phonenumber, rst_rating, rst_lat, rst_long, rst_tag, regionLabel, region2Label, imgpath, rst_like, member_id) "
				+ "VALUES ('대기', ?, ?, ?, ?, 0, ?, ?, ?, ?, ?, ?, 0, ?)";
		try {
			con = pool.getConnection();
			pstmt = con.prepareStatement(sql);
			pstmt.setString(1, bean.getRst_name());
			pstmt.setString(2, bean.getRst_introduction());
			pstmt.setString(3, bean.getRst_address());
			pstmt.setString(4, bean.getRst_phonenumber());
			pstmt.setDouble(5, bean.getRst_lat());
			pstmt.setDouble(6, bean.getRst_long());
			pstmt.setString(7, bean.getRst_tag());
			pstmt.setString(8, bean.getRegionLabel());
			pstmt.setString(9, bean.getRegion2Label());
			pstmt.setString(10, bean.getImgpath());
			pstmt.setString(11, bean.getMember_id()); // 여기 추가

			pstmt.executeUpdate();
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pool.freeConnection(con, pstmt);
		}
	}

	// 1-2. 식당 등록 (배치 등록: Vector 이용)
	public void insertRestaurant(Vector<RestaurantBean> vlist) {
		Connection con = null;
		PreparedStatement pstmt = null;
		String sql = "INSERT INTO restaurant VALUES (null, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
		try {
			con = pool.getConnection();
			pstmt = con.prepareStatement(sql);
			for (int i = 0; i < vlist.size(); i++) {
				RestaurantBean bean = vlist.get(i);
				pstmt.setString(1, bean.getRst_name());
				pstmt.setString(2, bean.getRst_address());
				pstmt.setString(3, bean.getRst_introduction());
				pstmt.setDouble(4, bean.getRst_lat());
				pstmt.setDouble(5, bean.getRst_long());
				pstmt.setString(6, bean.getRst_phonenumber());
				pstmt.setString(7, bean.getRst_tag());
				pstmt.setString(8, bean.getRegionLabel());
				pstmt.setString(9, bean.getRegion2Label());
				pstmt.setString(10, bean.getImgpath());
				pstmt.setInt(11, (bean.getRst_like() == null ? 0 : bean.getRst_like()));
				pstmt.setString(12, null); // created_at은 DB의 default(now()) 처리
				pstmt.addBatch();
			}
			int cnt[] = pstmt.executeBatch();
			System.out.println("cnt : " + cnt.length + " 성공");
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pool.freeConnection(con, pstmt);
		}
	}

	// 2. 승인 처리 (상태 변경)
	public void updateRestaurantStatus(int rst_id, String status) {
	    Connection con = null;
	    PreparedStatement pstmt = null;
	    ResultSet rs = null;
	    try {
	        con = pool.getConnection();
	        // 트랜잭션 시작
	        con.setAutoCommit(false);
	        
	        // 1. 식당 상태 변경
	        String sql = "UPDATE restaurant SET rst_status = ? WHERE rst_id = ?";
	        pstmt = con.prepareStatement(sql);
	        pstmt.setString(1, status); // 예: "승인"
	        pstmt.setInt(2, rst_id);
	        pstmt.executeUpdate();
	        pstmt.close();

	        // 2. member_id 조회
	        String selectSql = "SELECT member_id FROM restaurant WHERE rst_id = ?";
	        pstmt = con.prepareStatement(selectSql);
	        pstmt.setInt(1, rst_id);
	        rs = pstmt.executeQuery();

	        if (rs.next()) {
	            String memberId = rs.getString("member_id");
	            
	            // 알림 생성
	            String insertSql = "INSERT INTO notice (member_id, rst_id, is_read, status_info) VALUES (?, ?, 0, ?)";
	            pstmt = con.prepareStatement(insertSql);
	            pstmt.setString(1, memberId);
	            pstmt.setInt(2, rst_id);
	            pstmt.setString(3, status); // "승인" 또는 "거절"
	            pstmt.executeUpdate();
	        }
	        
	        // 트랜잭션 커밋
	        con.commit();
	        
	    } catch (Exception e) {
	        try {
	            // 오류 발생 시 롤백
	            if (con != null) con.rollback();
	        } catch (SQLException se) {
	            se.printStackTrace();
	        }
	        e.printStackTrace();
	    } finally {
	        try {
	            if (con != null) con.setAutoCommit(true);
	        } catch (SQLException se) {
	            se.printStackTrace();
	        }
	        pool.freeConnection(con, pstmt, rs);
	    }
	}


	// 식당 정보 수정 메서드
	public boolean updateRestaurantByMember(RestaurantBean bean) {
		Connection con = null;
		PreparedStatement pstmt = null;
		String sql = "UPDATE restaurant SET rst_name=?, rst_phonenumber=?, rst_address=?, rst_introduction=?, rst_tag=?, rst_status=?, rst_lat=?, rst_long=?, regionLabel=?, region2Label=?, imgpath=? WHERE rst_id=?";

		try {
			con = pool.getConnection();
			pstmt = con.prepareStatement(sql);
			pstmt.setString(1, bean.getRst_name());
			pstmt.setString(2, bean.getRst_phonenumber());
			pstmt.setString(3, bean.getRst_address());
			pstmt.setString(4, bean.getRst_introduction());
			pstmt.setString(5, bean.getRst_tag());
			pstmt.setString(6, bean.getRst_status());
			pstmt.setDouble(7, bean.getRst_lat());
			pstmt.setDouble(8, bean.getRst_long());
			pstmt.setString(9, bean.getRegionLabel());
			pstmt.setString(10, bean.getRegion2Label());
			pstmt.setString(11, bean.getImgpath());
			pstmt.setInt(12, bean.getRst_id());

			System.out.println("rst_id to update: " + bean.getRst_id());
			return pstmt.executeUpdate() > 0;
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pool.freeConnection(con, pstmt);
		}
		return false;
	}

	// 3. 거절 처리 (삭제 + 알림 생성)
	public void deleteRestaurant(int rst_id) {
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;

		try {
			con = pool.getConnection();

			// 1. member_id 조회
			String getSql = "SELECT member_id FROM restaurant WHERE rst_id = ?";
			pstmt = con.prepareStatement(getSql);
			pstmt.setInt(1, rst_id);
			rs = pstmt.executeQuery();

			String memberId = null;

			if (rs.next()) {
				memberId = rs.getString("member_id");
			}
			System.out.println("거절된 가게의 member_id = " + memberId);
			System.out.println("거절된 가게의 rst_id = " + rst_id);
			
			// 리소스 해제
			rs.close();
			pstmt.close();

			// 2. 알림 생성 (삭제되더라도 rst_id는 notice에 남겨둠)
			if (memberId != null) {
				String insertSql = "INSERT INTO notice (member_id, rst_id, is_read, status_info) VALUES (?, ?, 0, ?)";
				PreparedStatement insertStmt = con.prepareStatement(insertSql);
				insertStmt.setString(1, memberId);
				insertStmt.setInt(2, rst_id);
				insertStmt.setString(3, "거절"); // 또는 "승인"
				insertStmt.executeUpdate();
				insertStmt.close();
			}

			// 3. restaurant 삭제
			String delSql = "DELETE FROM restaurant WHERE rst_id = ?";
			pstmt = con.prepareStatement(delSql);
			pstmt.setInt(1, rst_id);
			pstmt.executeUpdate();
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pool.freeConnection(con, pstmt, rs);
		}
	}

	// 4. 승인 대기 식당 리스트 조회
	public Vector<RestaurantBean> getPendingRestaurants() {
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String sql = "SELECT * FROM restaurant WHERE rst_status = '대기' ORDER BY created_at DESC";
		Vector<RestaurantBean> list = new Vector<>();

		try {
			con = pool.getConnection();
			pstmt = con.prepareStatement(sql);
			rs = pstmt.executeQuery();

			while (rs.next()) {
				RestaurantBean bean = new RestaurantBean();
				bean.setRst_id(rs.getInt("rst_id"));
				bean.setRst_name(rs.getString("rst_name"));
				bean.setRst_address(rs.getString("rst_address"));
				bean.setRst_introduction(rs.getString("rst_introduction"));
				bean.setRst_phonenumber(rs.getString("rst_phonenumber"));
				bean.setRst_lat(rs.getDouble("rst_lat"));
				bean.setRst_long(rs.getDouble("rst_long"));
				bean.setRst_tag(rs.getString("rst_tag"));
				bean.setRegionLabel(rs.getString("regionLabel"));
				bean.setRegion2Label(rs.getString("region2Label"));
				bean.setImgpath(rs.getString("imgpath"));
				bean.setCreated_at(rs.getString("created_at"));
				list.add(bean);
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pool.freeConnection(con, pstmt, rs);
		}

		return list;
	}

	// member_id에 따른 식당 정보 조회
	public RestaurantBean getRestaurantByMemberId(String member_id) {
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		RestaurantBean bean = null;
		String sql = "SELECT * FROM restaurant WHERE member_id = ?";

		try {
			con = pool.getConnection();
			pstmt = con.prepareStatement(sql);
			pstmt.setString(1, member_id);
			rs = pstmt.executeQuery();
			if (rs.next()) {
				bean = new RestaurantBean();
				bean.setRst_id(rs.getInt("rst_id"));
				bean.setRst_status(rs.getString("rst_status"));
				bean.setRst_name(rs.getString("rst_name"));
				bean.setRst_introduction(rs.getString("rst_introduction"));
				bean.setRst_address(rs.getString("rst_address"));
				bean.setRst_phonenumber(rs.getString("rst_phonenumber"));
				bean.setRst_rating(rs.getDouble("rst_rating"));
				bean.setRst_lat(rs.getDouble("rst_lat"));
				bean.setRst_long(rs.getDouble("rst_long"));
				bean.setRst_tag(rs.getString("rst_tag"));
				bean.setRegionLabel(rs.getString("regionLabel"));
				bean.setRegion2Label(rs.getString("region2Label"));
				bean.setImgpath(rs.getString("imgpath"));
				bean.setRst_like(rs.getObject("rst_like") != null ? rs.getInt("rst_like") : null);
				bean.setCreated_at(rs.getString("created_at"));
				bean.setMember_id(rs.getString("member_id"));
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pool.freeConnection(con, pstmt, rs);
		}

		return bean;
	}

	public List<RestaurantBean> getRestaurantList() {
		List<RestaurantBean> list = new ArrayList<>();
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;

		try {
			con = pool.getConnection();
			String sql = "SELECT * FROM restaurant ORDER BY rst_id DESC";
			pstmt = con.prepareStatement(sql);
			rs = pstmt.executeQuery();

			while (rs.next()) {
				RestaurantBean bean = new RestaurantBean();
				bean.setRst_id(rs.getInt("rst_id"));
				bean.setRst_status(rs.getString("rst_status"));
				bean.setRst_name(rs.getString("rst_name"));
				bean.setRst_introduction(rs.getString("rst_introduction"));
				bean.setRst_address(rs.getString("rst_address"));
				bean.setRst_phonenumber(rs.getString("rst_phonenumber"));
				bean.setRst_rating(rs.getDouble("rst_rating"));
				bean.setRst_lat(rs.getDouble("rst_lat"));
				bean.setRst_long(rs.getDouble("rst_long"));
				bean.setRst_tag(rs.getString("rst_tag"));
				bean.setRegionLabel(rs.getString("regionLabel"));
				bean.setRegion2Label(rs.getString("region2Label"));
				bean.setImgpath(rs.getString("imgpath"));
				bean.setRst_like(rs.getObject("rst_like") != null ? rs.getInt("rst_like") : null);
				bean.setCreated_at(rs.getString("created_at"));
				bean.setMember_id(rs.getString("member_id"));
				list.add(bean);
			}

		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pool.freeConnection(con, pstmt, rs);
		}

		return list;
	}

	// 검색 조건을 포함한 가게 리스트 조회
	public List<RestaurantBean> getRestaurantListBySearch(int startRow, int pageSize, String searchType,
			String searchKeyword) {
		List<RestaurantBean> list = new ArrayList<>();
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;

		String sql = "SELECT * FROM restaurant WHERE 1=1";
		if (searchType != null && searchKeyword != null && !searchKeyword.trim().isEmpty()) {
			if ("name".equals(searchType)) {
				sql += " AND rst_name LIKE ?";
			} else if ("location".equals(searchType)) {
				sql += " AND (regionLabel LIKE ? OR region2Label LIKE ?)";
			}
		}
		sql += " ORDER BY rst_id DESC LIMIT ?, ?";

		try {
			con = pool.getConnection();
			pstmt = con.prepareStatement(sql);
			int idx = 1;
			if (searchType != null && searchKeyword != null && !searchKeyword.trim().isEmpty()) {
				if ("name".equals(searchType)) {
					pstmt.setString(idx++, "%" + searchKeyword + "%");
				} else if ("location".equals(searchType)) {
					pstmt.setString(idx++, "%" + searchKeyword + "%");
					pstmt.setString(idx++, "%" + searchKeyword + "%");
				}
			}
			pstmt.setInt(idx++, startRow);
			pstmt.setInt(idx, pageSize);

			rs = pstmt.executeQuery();
			while (rs.next()) {
				RestaurantBean bean = new RestaurantBean();
				bean.setRst_id(rs.getInt("rst_id"));
				bean.setRst_name(rs.getString("rst_name"));
				bean.setRegionLabel(rs.getString("regionLabel"));
				bean.setRegion2Label(rs.getString("region2Label"));
				bean.setCreated_at(rs.getString("created_at"));
				bean.setRst_like(rs.getObject("rst_like") != null ? rs.getInt("rst_like") : 0);
				list.add(bean);
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pool.freeConnection(con, pstmt, rs);
		}

		return list;
	}

	// 검색 조건 + 정렬 조건 포함한 전체 개수 조회
	public int getTotalCountBySearch(String searchType, String searchKeyword) {
		int count = 0;
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;

		String sql = "SELECT COUNT(*) FROM restaurant WHERE 1=1";
		if (searchType != null && searchKeyword != null && !searchKeyword.trim().isEmpty()) {
			if ("name".equals(searchType)) {
				sql += " AND rst_name LIKE ?";
			} else if ("location".equals(searchType)) {
				sql += " AND (regionLabel LIKE ? OR region2Label LIKE ?)";
			}
		}

		try {
			con = pool.getConnection();
			pstmt = con.prepareStatement(sql);
			int idx = 1;
			if (searchType != null && searchKeyword != null && !searchKeyword.trim().isEmpty()) {
				if ("name".equals(searchType)) {
					pstmt.setString(idx++, "%" + searchKeyword + "%");
				} else if ("location".equals(searchType)) {
					pstmt.setString(idx++, "%" + searchKeyword + "%");
					pstmt.setString(idx++, "%" + searchKeyword + "%");
				}
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

	// ====================================================
	// 2. 사용자 조회 기능
	// ====================================================

	// 2-1. 기본 맛집 리스트 조회 (필터 미적용)
	// 페이지네이션 포함 맛집 리스트 조회
	public List<RestaurantBean> getRestaurantList(int offset, int pageSize) {
		List<RestaurantBean> list = new ArrayList<>();
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;

		try {
			con = pool.getConnection();
			String sql = "SELECT * FROM restaurant ORDER BY rst_id DESC LIMIT ?, ?";
			pstmt = con.prepareStatement(sql);
			pstmt.setInt(1, offset);
			pstmt.setInt(2, pageSize);
			rs = pstmt.executeQuery();

			while (rs.next()) {
				RestaurantBean bean = new RestaurantBean();
				bean.setRst_id(rs.getInt("rst_id"));
				bean.setRst_status(rs.getString("rst_status"));
				bean.setRst_name(rs.getString("rst_name"));
				bean.setRst_introduction(rs.getString("rst_introduction"));
				bean.setRst_address(rs.getString("rst_address"));
				bean.setRst_phonenumber(rs.getString("rst_phonenumber"));
				bean.setRst_rating(rs.getDouble("rst_rating"));
				bean.setRst_lat(rs.getDouble("rst_lat"));
				bean.setRst_long(rs.getDouble("rst_long"));
				bean.setRst_tag(rs.getString("rst_tag"));
				bean.setRegionLabel(rs.getString("regionLabel"));
				bean.setRegion2Label(rs.getString("region2Label"));
				bean.setImgpath(rs.getString("imgpath"));
				bean.setRst_like(rs.getObject("rst_like") != null ? rs.getInt("rst_like") : null);
				bean.setCreated_at(rs.getString("created_at"));
				bean.setMember_id(rs.getString("member_id"));
				list.add(bean);
			}

		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pool.freeConnection(con, pstmt, rs);
		}

		return list;
	}

	// 2-2. 필터 조건(테마, 지역)을 적용한 맛집 리스트 조회
	public Vector<RestaurantBean> getRestaurantList(int offset, int pageSize, String tag, String region, String sort) {
	    Vector<RestaurantBean> v = new Vector<>();
	    Connection con = null;
	    PreparedStatement pstmt = null;
	    ResultSet rs = null;
	    // 기본 SQL 작성
	    String sql = "SELECT rst_id, rst_name, rst_address, rst_introduction, rst_lat, rst_long, "
	               + "rst_phonenumber, rst_tag, regionLabel, region2Label, imgpath, rst_like "
	               + "FROM restaurant WHERE 1=1";
	    // 필터 조건 추가
	    if (tag != null && !tag.isEmpty()) {
	        sql += " AND rst_tag LIKE ?";
	    }
	    if (region != null && !region.isEmpty()) {
	        sql += " AND regionLabel = ?";
	    }
	    // 정렬 조건 추가
	    if ("popular".equals(sort)) {
	        sql += " ORDER BY rst_like DESC, rst_id DESC";
	    } else if ("rating".equals(sort)) {
	        sql += " ORDER BY rst_rating DESC, rst_id DESC";
	    } else {
	        sql += " ORDER BY rst_id DESC";
	    }
	    sql += " LIMIT ?, ?";
	    
	    try {
	        con = pool.getConnection();
	        pstmt = con.prepareStatement(sql);
	        int idx = 1;
	        if (tag != null && !tag.isEmpty()) {
	            pstmt.setString(idx++, "%" + tag + "%");
	        }
	        if (region != null && !region.isEmpty()) {
	            pstmt.setString(idx++, region);
	        }
	        pstmt.setInt(idx++, offset);
	        pstmt.setInt(idx, pageSize);
	        rs = pstmt.executeQuery();
	        while (rs.next()) {
	            RestaurantBean bean = new RestaurantBean();
	            bean.setRst_id(rs.getInt("rst_id"));
	            bean.setRst_name(rs.getString("rst_name"));
	            bean.setRst_address(rs.getString("rst_address"));
	            bean.setRst_introduction(rs.getString("rst_introduction"));
	            bean.setRst_phonenumber(rs.getString("rst_phonenumber"));
	            bean.setRst_lat(rs.getDouble("rst_lat"));
	            bean.setRst_long(rs.getDouble("rst_long"));
	            bean.setRst_tag(rs.getString("rst_tag"));
	            bean.setRegionLabel(rs.getString("regionLabel"));
	            bean.setRegion2Label(rs.getString("region2Label"));
	            bean.setImgpath(rs.getString("imgpath"));
	            // rst_like가 null일 경우도 고려
	            bean.setRst_like(rs.getObject("rst_like") != null ? rs.getInt("rst_like") : 0);
	            v.add(bean);
	        }
	    } catch (Exception e) {
	        e.printStackTrace();
	    } finally {
	        pool.freeConnection(con, pstmt, rs);
	    }
	    return v;
	}


	// 2-3. 기본 전체 맛집 개수 조회 (필터 미적용)
	public int getTotalCount() {
		int count = 0;
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		try {
			con = pool.getConnection();
			String sql = "SELECT COUNT(*) FROM restaurant";
			pstmt = con.prepareStatement(sql);
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

	// 2-4. 필터 조건(테마, 지역)을 적용한 맛집 개수 조회
	public int getTotalCount(String tag, String region) {
		int count = 0;
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String sql = "SELECT COUNT(*) FROM restaurant WHERE 1=1";
		if (tag != null && !tag.isEmpty()) {
			sql += " AND rst_tag LIKE ?";
		}
		if (region != null && !region.isEmpty()) {
			sql += " AND regionLabel = ?";
		}
		try {
			con = pool.getConnection();
			pstmt = con.prepareStatement(sql);
			int idx = 1;
			if (tag != null && !tag.isEmpty()) {
				pstmt.setString(idx++, "%" + tag + "%");
			}
			if (region != null && !region.isEmpty()) {
				pstmt.setString(idx++, region);
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

	// 2-5. 모든 distinct 태그 반환 (rst_tag 기준)
	public Vector<String> getDistinctThemeTags() {
		Vector<String> tags = new Vector<>();
		HashSet<String> set = new HashSet<>();
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String sql = "SELECT rst_tag FROM restaurant";
		try {
			con = pool.getConnection();
			pstmt = con.prepareStatement(sql);
			rs = pstmt.executeQuery();
			while (rs.next()) {
				String alltag = rs.getString("rst_tag");
				if (alltag != null && !alltag.trim().isEmpty()) {
					String[] parts = alltag.split("[,\\s]+");
					for (String part : parts) {
						part = part.trim();
						if (!part.isEmpty()) {
							set.add(part);
						}
					}
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pool.freeConnection(con, pstmt, rs);
		}
		tags.addAll(set);
		return tags;
	}

	// 2-6. DISTINCT한 regionLabel과 region2Label 추출
	public Vector<RestaurantBean> getDistinctRegionTags() {
		Vector<RestaurantBean> v = new Vector<>();
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String sql = "SELECT DISTINCT regionLabel, region2Label FROM restaurant";
		try {
			con = pool.getConnection();
			pstmt = con.prepareStatement(sql);
			rs = pstmt.executeQuery();
			while (rs.next()) {
				RestaurantBean bean = new RestaurantBean();
				bean.setRegionLabel(rs.getString("regionLabel"));
				bean.setRegion2Label(rs.getString("region2Label"));
				v.add(bean);
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pool.freeConnection(con, pstmt, rs);
		}
		return v;
	}

	// 2-7. 맛집 상세 정보 조회 (rst_id 기준)
	public RestaurantBean getRestaurantDetail(int rst_id) {
		RestaurantBean bean = null;
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String sql = "SELECT rst_id, rst_name, rst_address, rst_introduction, rst_lat, rst_long, "
				+ "rst_phonenumber, rst_tag, regionLabel, region2Label, imgpath, rst_like, member_id, rst_rating "
				+ "FROM restaurant WHERE rst_id = ?";
		try {
			con = pool.getConnection();
			pstmt = con.prepareStatement(sql);
			pstmt.setInt(1, rst_id);
			rs = pstmt.executeQuery();
			if (rs.next()) {
				bean = new RestaurantBean();
				bean.setRst_id(rs.getInt("rst_id"));
				bean.setRst_name(rs.getString("rst_name"));
				bean.setRst_address(rs.getString("rst_address"));
				bean.setRst_introduction(rs.getString("rst_introduction"));
				bean.setRst_lat(rs.getDouble("rst_lat"));
				bean.setRst_long(rs.getDouble("rst_long"));
				bean.setRst_phonenumber(rs.getString("rst_phonenumber"));
				bean.setRst_tag(rs.getString("rst_tag"));
				bean.setRegionLabel(rs.getString("regionLabel"));
				bean.setRegion2Label(rs.getString("region2Label"));
				bean.setImgpath(rs.getString("imgpath"));
				bean.setRst_like(rs.getInt("rst_like"));
				bean.setMember_id(rs.getString("member_id"));
				bean.setRst_rating(rs.getDouble("rst_rating"));
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pool.freeConnection(con, pstmt, rs);
		}
		return bean;
	}

	// 2-8. 관련 맛집 조회 (현재 맛집 제외, tag 조건, 최대 5건)
	public Vector<RestaurantBean> getRelatedRestaurants(int rst_id, String tag) {
		Vector<RestaurantBean> v = new Vector<>();
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String sql = "SELECT rst_id, rst_name, rst_address, rst_introduction, rst_lat, rst_long, "
				+ "rst_phonenumber, rst_tag, regionLabel, region2Label, imgpath, rst_like "
				+ "FROM restaurant WHERE rst_id <> ? AND rst_tag LIKE ? LIMIT 5";
		try {
			con = pool.getConnection();
			pstmt = con.prepareStatement(sql);
			pstmt.setInt(1, rst_id);
			pstmt.setString(2, "%" + tag + "%");
			rs = pstmt.executeQuery();
			while (rs.next()) {
				RestaurantBean bean = new RestaurantBean();
				bean.setRst_id(rs.getInt("rst_id"));
				bean.setRst_name(rs.getString("rst_name"));
				bean.setRst_address(rs.getString("rst_address"));
				bean.setRst_introduction(rs.getString("rst_introduction"));
				bean.setRst_lat(rs.getDouble("rst_lat"));
				bean.setRst_long(rs.getDouble("rst_long"));
				bean.setRst_phonenumber(rs.getString("rst_phonenumber"));
				bean.setRst_tag(rs.getString("rst_tag"));
				bean.setRegionLabel(rs.getString("regionLabel"));
				bean.setRegion2Label(rs.getString("region2Label"));
				bean.setImgpath(rs.getString("imgpath"));
				bean.setRst_like(rs.getInt("rst_like"));
				v.add(bean);
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pool.freeConnection(con, pstmt, rs);
		}
		return v;
	}

    public int RSTCountRegion(String region) {
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String sql = null;
		int count = 0;
		try {
			con = pool.getConnection();
			// 매개변수가 없으면 전체 검색, 있으면 특정 지역 검색
			if (region == null || region.isEmpty()) {
				sql = "SELECT COUNT(*) FROM restaurant WHERE rst_status = '승인'";
				pstmt = con.prepareStatement(sql);
			} else {
				sql = "SELECT COUNT(*) FROM restaurant WHERE regionLabel = ? AND rst_status = '승인'";
				pstmt = con.prepareStatement(sql);
				pstmt.setString(1, region);
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

	public Vector<RestaurantBean> getRestaurantListByKeyword(String keyword) {
		Vector<RestaurantBean> vlist = new Vector<RestaurantBean>();
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;

		String sql = "SELECT rst_id, rst_name, rst_address, rst_lat, rst_long, imgpath " + "FROM restaurant "
				+ "WHERE rst_name LIKE ? " + "ORDER BY rst_name ASC";
		try {
			con = pool.getConnection();
			pstmt = con.prepareStatement(sql);
			pstmt.setString(1, keyword);
			rs = pstmt.executeQuery();
			while (rs.next()) {
				RestaurantBean bean = new RestaurantBean();
				bean.setRst_id(rs.getInt("rst_id"));
				bean.setRst_name(rs.getString("rst_name"));
				bean.setRst_address(rs.getString("rst_address"));
				bean.setRst_lat(rs.getDouble("rst_lat"));
				bean.setRst_long(rs.getDouble("rst_long"));
				bean.setImgpath(rs.getString("imgpath"));
				vlist.add(bean);
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pool.freeConnection(con, pstmt, rs);
		}
		return vlist;
	}
	
    public RestaurantBean getRestaurantByName(String name) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        RestaurantBean bean = null;

        String sql = "SELECT * FROM restaurant WHERE TRIM(rst_name) = ?";
        try {
            con = pool.getConnection();
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, name.trim()); // 중요
            rs = pstmt.executeQuery();
            if (rs.next()) {
                bean = new RestaurantBean();
                bean.setRst_id(rs.getInt("rst_id")); // ✅ 이거 꼭 필요함!
                bean.setRst_name(rs.getString("rst_name"));
                bean.setImgpath(rs.getString("imgpath"));
                bean.setRst_lat(rs.getDouble("rst_lat"));      // ✅ 반드시 이거 들어가야 함
                bean.setRst_long(rs.getDouble("rst_long")); 
                bean.setRst_address(rs.getString("rst_address"));
                bean.setRst_introduction(rs.getString("rst_introduction"));
                // ... 나머지 필드도 필요하면 세팅
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt, rs);
        }
        return bean;
    }
    
    public Vector<RestaurantBean> searchRestaurants(String keyword) {
        Vector<RestaurantBean> vlist = new Vector<RestaurantBean>();
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        // 음식점명(rst_name)과 태그(rst_tag)를 모두 검색 대상으로 포함
        String sql = "SELECT * FROM restaurant WHERE rst_name LIKE ? OR rst_tag LIKE ? ORDER BY rst_name ASC";
        try {
            con = pool.getConnection();
            pstmt = con.prepareStatement(sql);
            String searchPattern = "%" + keyword + "%";
            pstmt.setString(1, searchPattern);
            pstmt.setString(2, searchPattern);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                RestaurantBean bean = new RestaurantBean();
                bean.setRst_id(rs.getInt("rst_id"));
                bean.setRst_status(rs.getString("rst_status"));
                bean.setRst_name(rs.getString("rst_name"));
                bean.setRst_introduction(rs.getString("rst_introduction"));
                bean.setRst_address(rs.getString("rst_address"));
                bean.setRst_phonenumber(rs.getString("rst_phonenumber"));
                bean.setRst_rating(rs.getDouble("rst_rating"));
                bean.setRst_lat(rs.getDouble("rst_lat"));
                bean.setRst_long(rs.getDouble("rst_long"));
                bean.setRst_tag(rs.getString("rst_tag"));
                bean.setRegionLabel(rs.getString("regionLabel"));
                bean.setRegion2Label(rs.getString("region2Label"));
                bean.setImgpath(rs.getString("imgpath"));
                bean.setRst_like(rs.getObject("rst_like") != null ? rs.getInt("rst_like") : null);
                bean.setCreated_at(rs.getString("created_at"));
                bean.setMember_id(rs.getString("member_id"));
                vlist.add(bean);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt, rs);
        }
        return vlist;
    }

    
    public int getTotalCountByAllFields(String keyword) {
        int count = 0;
        String sql = "SELECT COUNT(*) FROM restaurant WHERE rst_name LIKE ? OR rst_address LIKE ?";
        try (Connection con = pool.getConnection();
             PreparedStatement pstmt = con.prepareStatement(sql)) {
            String like = "%" + keyword + "%";
            pstmt.setString(1, like);
            pstmt.setString(2, like);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) count = rs.getInt(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return count;
    }

    public List<RestaurantBean> getRestaurantListByAllFields(int start, int pageSize, String keyword) {
        List<RestaurantBean> list = new ArrayList<>();
        String sql = "SELECT * FROM restaurant WHERE rst_name LIKE ? OR rst_address LIKE ? ORDER BY created_at DESC LIMIT ?, ?";
        try (Connection con = pool.getConnection();
             PreparedStatement pstmt = con.prepareStatement(sql)) {
            String like = "%" + keyword + "%";
            pstmt.setString(1, like);
            pstmt.setString(2, like);
            pstmt.setInt(3, start);
            pstmt.setInt(4, pageSize);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                RestaurantBean bean = new RestaurantBean();
                // 필요 시 필드 세팅
                bean.setRst_id(rs.getInt("rst_id"));
                bean.setRst_name(rs.getString("rst_name"));
                bean.setRst_address(rs.getString("rst_address"));
	            bean.setRegionLabel(rs.getString("regionLabel"));
	            bean.setRegion2Label(rs.getString("region2Label"));
                bean.setCreated_at(rs.getString("created_at"));
                bean.setRst_like(rs.getInt("rst_like"));
                // ... 기타 필요한 필드 추가
                list.add(bean);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    
 // 가게 승인과 역할 업데이트 메서드 수정
    public boolean approveRestaurantAndUpdateRole(int rstId) {
        Connection con = null;
        PreparedStatement pstmt1 = null;
        PreparedStatement pstmt2 = null;
        ResultSet rs = null;

        try {
            con = pool.getConnection();
            // 트랜잭션 시작
            con.setAutoCommit(false);

            // 1. 가게 승인
            String sql1 = "UPDATE restaurant SET rst_status = '승인' WHERE rst_id = ?";
            pstmt1 = con.prepareStatement(sql1);
            pstmt1.setInt(1, rstId);
            int result1 = pstmt1.executeUpdate();

            if (result1 > 0) {
                // 2. member_id 가져오기
                String sql2 = "SELECT member_id FROM restaurant WHERE rst_id = ?";
                pstmt2 = con.prepareStatement(sql2);
                pstmt2.setInt(1, rstId);
                rs = pstmt2.executeQuery();

                if (rs.next()) {
                    String memberId = rs.getString("member_id");

                    // 3. member_role 업데이트
                    String sql3 = "UPDATE member SET member_role = '가게사장' WHERE member_id = ?";
                    try (PreparedStatement pstmt3 = con.prepareStatement(sql3)) {
                        pstmt3.setString(1, memberId);
                        pstmt3.executeUpdate();
                    }
                    
                    // 4. 알림 생성
                    String insertSql = "INSERT INTO notice (member_id, rst_id, is_read, status_info) VALUES (?, ?, 0, '승인')";
                    try (PreparedStatement insertStmt = con.prepareStatement(insertSql)) {
                        insertStmt.setString(1, memberId);
                        insertStmt.setInt(2, rstId);
                        insertStmt.executeUpdate();
                    }
                }
                // 트랜잭션 커밋
                con.commit();
                return true;
            }

        } catch (Exception e) {
            try {
                // 오류 발생 시 롤백
                if (con != null) con.rollback();
            } catch (SQLException se) {
                se.printStackTrace();
            }
            e.printStackTrace();
        } finally {
            try {
                if (con != null) con.setAutoCommit(true);
            } catch (SQLException se) {
                se.printStackTrace();
            }
            pool.freeConnection(con, pstmt1, rs);
        }
        return false;
    }
    
    public boolean deleteRestaurantAndMaybeUpdateRole(int rstId) {
        Connection con = null;
        PreparedStatement pstmt1 = null;
        PreparedStatement pstmt2 = null;
        PreparedStatement pstmt3 = null;
        PreparedStatement pstmt4 = null;
        ResultSet rs = null;

        try {
            con = pool.getConnection();
            con.setAutoCommit(false); // 🔐 트랜잭션 시작

            // 1. member_id 조회
            String sql1 = "SELECT member_id FROM restaurant WHERE rst_id = ?";
            pstmt1 = con.prepareStatement(sql1);
            pstmt1.setInt(1, rstId);
            rs = pstmt1.executeQuery();

            if (rs.next()) {
                String memberId = rs.getString("member_id");
                rs.close();
                pstmt1.close();

                // 2. 알림 생성 ("거절")
                String insertSql = "INSERT INTO notice (member_id, rst_id, is_read, status_info) VALUES (?, ?, 0, '거절')";
                pstmt2 = con.prepareStatement(insertSql);
                pstmt2.setString(1, memberId);
                pstmt2.setInt(2, rstId);
                pstmt2.executeUpdate();
                pstmt2.close();

                // 3. restaurant 삭제
                String sql2 = "DELETE FROM restaurant WHERE rst_id = ?";
                pstmt3 = con.prepareStatement(sql2);
                pstmt3.setInt(1, rstId);
                int result = pstmt3.executeUpdate();
                pstmt3.close();

                if (result > 0) {
                    // 4. 남은 승인된 가게 수 확인
                    String sql3 = "SELECT COUNT(*) FROM restaurant WHERE member_id = ? AND rst_status = '승인'";
                    pstmt4 = con.prepareStatement(sql3);
                    pstmt4.setString(1, memberId);
                    ResultSet rs2 = pstmt4.executeQuery();

                    if (rs2.next() && rs2.getInt(1) == 0) {
                        // 5. 일반회원으로 롤백
                        String sql4 = "UPDATE member SET member_role = '일반회원' WHERE member_id = ?";
                        try (PreparedStatement pstmt5 = con.prepareStatement(sql4)) {
                            pstmt5.setString(1, memberId);
                            pstmt5.executeUpdate();
                        }
                    }
                    rs2.close();
                    pstmt4.close();
                }

                con.commit(); // 💾 트랜잭션 확정
                return true;
            }

        } catch (Exception e) {
            try {
                if (con != null) con.rollback(); // ❌ 롤백
            } catch (SQLException se) {
                se.printStackTrace();
            }
            e.printStackTrace();
        } finally {
            try {
                if (con != null) con.setAutoCommit(true);
            } catch (SQLException se) {
                se.printStackTrace();
            }
            pool.freeConnection(con, pstmt1, rs);
        }

        return false;
    }

    
 // ===== RestaurantMgr.java =====

 // 1) 검색 결과 전체 건수 조회
 public int countSearchRestaurants(String keyword) {
     int count = 0;
     String sql = "SELECT COUNT(*) FROM restaurant WHERE rst_name LIKE ? OR rst_tag LIKE ?";
     try (Connection con = pool.getConnection();
          PreparedStatement pstmt = con.prepareStatement(sql)) {
         String pattern = "%" + keyword + "%";
         pstmt.setString(1, pattern);
         pstmt.setString(2, pattern);
         try (ResultSet rs = pstmt.executeQuery()) {
             if (rs.next()) {
                 count = rs.getInt(1);
             }
         }
     } catch (Exception e) {
         e.printStackTrace();
     }
     return count;
 }

 // 2) 검색 결과 페이징 조회
 public Vector<RestaurantBean> searchRestaurants(String keyword, int offset, int pageSize) {
     Vector<RestaurantBean> vlist = new Vector<>();
     String sql = "SELECT * FROM restaurant "
                + "WHERE rst_name LIKE ? OR rst_tag LIKE ? "
                + "ORDER BY rst_name ASC LIMIT ?, ?";
     try (Connection con = pool.getConnection();
          PreparedStatement pstmt = con.prepareStatement(sql)) {
         String pattern = "%" + keyword + "%";
         pstmt.setString(1, pattern);
         pstmt.setString(2, pattern);
         pstmt.setInt(3, offset);
         pstmt.setInt(4, pageSize);
         try (ResultSet rs = pstmt.executeQuery()) {
             while (rs.next()) {
                 RestaurantBean bean = new RestaurantBean();
                 bean.setRst_id(rs.getInt("rst_id"));
                 bean.setRst_status(rs.getString("rst_status"));
                 bean.setRst_name(rs.getString("rst_name"));
                 bean.setRst_introduction(rs.getString("rst_introduction"));
                 bean.setRst_address(rs.getString("rst_address"));
                 bean.setRst_phonenumber(rs.getString("rst_phonenumber"));
                 bean.setRst_rating(rs.getDouble("rst_rating"));
                 bean.setRst_lat(rs.getDouble("rst_lat"));
                 bean.setRst_long(rs.getDouble("rst_long"));
                 bean.setRst_tag(rs.getString("rst_tag"));
                 bean.setRegionLabel(rs.getString("regionLabel"));
                 bean.setRegion2Label(rs.getString("region2Label"));
                 bean.setImgpath(rs.getString("imgpath"));
                 bean.setRst_like(rs.getObject("rst_like") != null ? rs.getInt("rst_like") : 0);
                 bean.setCreated_at(rs.getString("created_at"));
                 bean.setMember_id(rs.getString("member_id"));
                 vlist.add(bean);
             }
         }
     } catch (Exception e) {
         e.printStackTrace();
     }
     return vlist;
 }




}
