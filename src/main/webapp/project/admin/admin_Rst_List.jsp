<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*,project.RestaurantMgr, project.RestaurantBean" %>
<%
    String searchType = request.getParameter("searchType");
    String searchKeyword = request.getParameter("searchKeyword");
    int pageSize = 9;
    String pageNumParam = request.getParameter("pageNum");
    int currentPage = pageNumParam != null ? Integer.parseInt(pageNumParam) : 1;
    int startRow = (currentPage - 1) * pageSize;

    RestaurantMgr mgr = new RestaurantMgr();

    boolean hasKeyword = (searchKeyword != null && !searchKeyword.trim().isEmpty());
    boolean isAllSearch = (searchType == null || searchType.trim().isEmpty());

    int totalCount;
    List<RestaurantBean> list;

    if (hasKeyword && isAllSearch) {
        totalCount = mgr.getTotalCountByAllFields(searchKeyword);
        list = mgr.getRestaurantListByAllFields(startRow, pageSize, searchKeyword);
    } else if (hasKeyword) {
        totalCount = mgr.getTotalCountBySearch(searchType, searchKeyword);
        list = mgr.getRestaurantListBySearch(startRow, pageSize, searchType, searchKeyword);
    } else {
        totalCount = mgr.getTotalCount();
        list = mgr.getRestaurantList(startRow, pageSize);
    }

    int totalPage = (int) Math.ceil((double) totalCount / pageSize);
    int no = totalCount - startRow;
    int pageBlock = 5;
    int startPage = ((currentPage - 1) / pageBlock) * pageBlock + 1;
    int endPage = Math.min(startPage + pageBlock - 1, totalPage);
    String contextPath = request.getContextPath();
%>


<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>가게 승인/관리 - YUMMY JEJU</title>
  <link rel="stylesheet" href="../css/admin_Rst_List.css">
</head>
<body>
    <%
      String deleteSuccess = request.getParameter("deleteSuccess");
      if ("true".equals(deleteSuccess)) {
    %>
      <script>alert("삭제가 완료되었습니다.");</script>
    <%
      }
    %>
    
    <!-- 사이드바 및 헤더 인클루드 -->
    <%@ include file="../admin_Header.jsp" %>

    <!-- 메인 컨텐츠 영역 -->
    <div class="main-content">
        <!-- 가게 리스트 섹션 - 향상된 UI -->
        <section class="approval-section">
          <h2>가게 승인/관리</h2>
          
          <!-- 탭 메뉴 - 위치 유지 -->
          <div class="tabs">
            <a href="admin_Rst_Approval.jsp" class="tab-btn">승인 대기</a>
            <a href="admin_Rst_List.jsp" class="tab-btn active">가게 리스트</a>
          </div>

          <!-- 검색 바 - 향상된 UI -->
          <form method="get" class="search-bar">
            <select name="searchType" class="filter-select">
              <option value="" <%= (searchType == null || searchType.isEmpty()) ? "selected" : "" %>>전체</option>
              <option value="name" <%= "name".equals(searchType) ? "selected" : "" %>>가게 이름</option>
              <option value="location" <%= "location".equals(searchType) ? "selected" : "" %>>위치</option>
            </select>
            <input type="text" name="searchKeyword" class="search-input" placeholder="검색어를 입력하세요" value="<%= searchKeyword != null ? searchKeyword : "" %>"/>
            <button type="submit" class="search-btn">검색</button>
          </form>

          <!-- 테이블 - 향상된 UI -->
          <div class="table-container">
            <table>
              <thead>
                <tr>
                  <th>No</th>
                  <th>가게 이름</th>
                  <th>위치</th>
                  <th>등록일</th>
                  <th>좋아요</th>
                  <th>상세보기</th>
                  <th>삭제</th>
                </tr>
              </thead>
              <tbody>
              <% if (list.isEmpty()) { %>
                <tr><td colspan="7">등록된 가게가 없습니다.</td></tr>
              <% } else {
                  for (RestaurantBean bean : list) {
              %>
                <tr>
                  <td><%= no-- %></td>
                  <td><%= bean.getRst_name() %></td>
                  <td><%= bean.getRegionLabel() %> <%= bean.getRegion2Label() %></td>
                  <td><%= bean.getCreated_at() != null ? bean.getCreated_at().toString().substring(0, 10) : "" %></td>
                  <td><%= bean.getRst_like() != null ? bean.getRst_like() : 0 %></td>
                  <td>
                    <form method="get" action="admin_Rst_List_Detail.jsp" style="display:inline;">
                      <input type="hidden" name="rst_id" value="<%= bean.getRst_id() %>">
                      <button type="submit">상세보기</button>
                    </form>
                  </td>
                  <td>
                    <form method="post" action="<%= contextPath %>/deleteRestaurant" style="display:inline;" onsubmit="return confirm('정말 삭제하시겠습니까?');">
                      <input type="hidden" name="rst_id" value="<%= bean.getRst_id() %>">
                      <input type="hidden" name="pageNum" value="<%= currentPage %>">
                      <input type="hidden" name="searchType" value="<%= searchType != null ? searchType : "" %>">
                      <input type="hidden" name="searchKeyword" value="<%= searchKeyword != null ? searchKeyword : "" %>">
                      <button type="submit">삭제</button>
                    </form>
                  </td>
                </tr>
              <%
                  }
                }
              %>
              </tbody>
            </table>
          </div>

          <!-- 페이지네이션 - 향상된 UI -->
          <% if (totalPage > 0) { %>
          <div class="pagination">
            <% if (currentPage > 1) { %>
              <a href="admin_Rst_List.jsp?pageNum=1&searchType=<%= searchType != null ? searchType : "" %>&searchKeyword=<%= searchKeyword != null ? searchKeyword : "" %>" title="처음으로">&laquo;</a>
            <% } %>

            <% if (startPage > 1) { %>
              <a href="admin_Rst_List.jsp?pageNum=<%= startPage - 1 %>&searchType=<%= searchType != null ? searchType : "" %>&searchKeyword=<%= searchKeyword != null ? searchKeyword : "" %>" title="이전">&lsaquo;</a>
            <% } %>

            <% for (int i = startPage; i <= endPage; i++) {
                 if (i == currentPage) { %>
              <strong><%= i %></strong>
            <%   } else { %>
              <a href="admin_Rst_List.jsp?pageNum=<%= i %>&searchType=<%= searchType != null ? searchType : "" %>&searchKeyword=<%= searchKeyword != null ? searchKeyword : "" %>"><%= i %></a>
            <%   }
               } %>

            <% if (endPage < totalPage) { %>
              <a href="admin_Rst_List.jsp?pageNum=<%= endPage + 1 %>&searchType=<%= searchType != null ? searchType : "" %>&searchKeyword=<%= searchKeyword != null ? searchKeyword : "" %>" title="다음">&rsaquo;</a>
            <% } %>

            <% if (currentPage < totalPage) { %>
              <a href="admin_Rst_List.jsp?pageNum=<%= totalPage %>&searchType=<%= searchType != null ? searchType : "" %>&searchKeyword=<%= searchKeyword != null ? searchKeyword : "" %>" title="마지막으로">&raquo;</a>
            <% } %>
          </div>
          <% } %>
          
          <!-- 현재 상태 표시 -->
          <div class="status-info">
            <p>전체 <%= totalCount %>개의 가게 중 <%= Math.min(list.size(), pageSize) %>개 표시 (페이지 <%= currentPage %>/<%= totalPage == 0 ? 1 : totalPage %>)</p>
          </div>
        </section>
    </div>
</body>
</html>