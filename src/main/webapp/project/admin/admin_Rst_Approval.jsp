<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="project.RestaurantMgr, project.RestaurantBean" %>
<%@ page import="java.util.Vector" %>
<%
    request.setCharacterEncoding("UTF-8");

    String action = request.getParameter("action");
    String idStr = request.getParameter("rst_id");
    String searchType = request.getParameter("searchType");
    String searchKeyword = request.getParameter("searchKeyword");


    if (action != null && idStr != null) {
        int rst_id = Integer.parseInt(idStr);
        RestaurantMgr mgr = new RestaurantMgr();

        if ("approve".equals(action)) {
            mgr.updateRestaurantStatus(rst_id, "승인");
        } else if ("reject".equals(action)) {
            mgr.deleteRestaurant(rst_id);
        }

        response.sendRedirect("admin_Rst_Approval.jsp");
        return;
    }

    int pageSize = 5;
    int pageNum = 1;
    try {
        pageNum = Integer.parseInt(request.getParameter("pageNum"));
        if (pageNum < 1) pageNum = 1;
    } catch (Exception e) {
        pageNum = 1;
    }
    int startRow = (pageNum - 1) * pageSize;

    RestaurantMgr mgr = new RestaurantMgr();
    Vector<RestaurantBean> fullList = mgr.getPendingRestaurants();
    int totalCount = fullList.size();
    int totalPage = (int) Math.ceil((double) totalCount / pageSize);
    if (pageNum > totalPage && totalPage > 0) pageNum = totalPage;

    int pageBlock = 5;
    int startPage = ((pageNum - 1) / pageBlock) * pageBlock + 1;
    int endPage = Math.min(startPage + pageBlock - 1, totalPage);
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>가게 승인/관리 - YUMMY JEJU</title>
    <link rel="stylesheet" href="../css/admin_Rst_Approval.css">
    <script>
        function confirmReject(formElement) {
            if(confirm('정말로 이 가게 등록을 거절하시겠습니까?')) {
                formElement.submit();
            }
            return false;
        }
    </script>
</head>
<body>
    <!-- 사이드바 및 헤더 인클루드 -->
    <%@ include file="../admin_Header.jsp" %>

    <!-- 메인 컨텐츠 영역 -->
    <main class="main-content">
        <!-- 가게 승인 섹션 - 향상된 UI -->
        <section class="approval-section">
            <h2>가게 승인/관리</h2>
            
            <div class="tabs">
                <a href="admin_Rst_Approval.jsp" class="tab-btn active">승인 대기</a>
                <a href="admin_Rst_List.jsp" class="tab-btn">가게 리스트</a>
            </div>

            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>식당 이름</th>
                            <th>주소</th>
                            <th>승인 요청일</th>
                            <th>관리</th>
                        </tr>
                    </thead>
                    <tbody>
					    <% if (totalCount == 0) { %>
					        <tr><td colspan="4">승인 대기 중인 식당이 없습니다.</td></tr>
					    <% } else {
					        int endRow = Math.min(startRow + pageSize, totalCount);
					        for (int i = startRow; i < endRow; i++) {
					            RestaurantBean bean = fullList.get(i);
					    %>
					        <tr>
					            <td><%= bean.getRst_name() %></td>
					            <td><%= bean.getRst_address() %></td>
					            <td><%= bean.getCreated_at() != null ? bean.getCreated_at().toString().substring(0, 10) : "" %></td>
					            <td class="actions">
					                <!-- 승인 버튼 -->
					                <form method="post" action="<%= request.getContextPath() %>/RstApproveServlet" style="display:inline;">
					                    <input type="hidden" name="rst_id" value="<%= bean.getRst_id() %>">
					                    <input type="hidden" name="pageNum" value="<%= pageNum %>">
					                    <input type="hidden" name="searchType" value="<%= searchType != null ? searchType : "" %>">
					                    <input type="hidden" name="searchKeyword" value="<%= searchKeyword != null ? searchKeyword : "" %>">
					                    <button type="submit" class="approve">승인</button>
					                </form>
					
					                <!-- 거절 버튼 = 삭제 -->
					                <form method="post" action="<%= request.getContextPath() %>/deleteRestaurant" style="display:inline;" onsubmit="return confirm('정말 거절하시겠습니까?');">
					                    <input type="hidden" name="rst_id" value="<%= bean.getRst_id() %>">
					                    <input type="hidden" name="pageNum" value="<%= pageNum %>">
					                    <input type="hidden" name="searchType" value="<%= searchType != null ? searchType : "" %>">
					                    <input type="hidden" name="searchKeyword" value="<%= searchKeyword != null ? searchKeyword : "" %>">
					                    <button type="submit" class="reject">거절</button>
					                </form>
					            </td>
					        </tr>
					    <% } } %>
					</tbody>

                </table>
            </div>

            <!-- 페이지네이션 영역 -->
            <% if (totalPage > 0) { %>
            <div class="pagination">
                <% for (int i = startPage; i <= endPage; i++) {
                    if (i == pageNum) { %>
                        <strong><%= i %></strong>
                    <% } else { %>
                        <a href="?pageNum=<%= i %>"><%= i %></a>
                    <% } 
                } %>
            </div>
            <% } %>
            
            <!-- 현재 상태 표시 -->
            <div class="status-info">
                <p>총 <%= totalCount %>개의 승인 대기 중인 식당이 있습니다.</p>
            </div>
        </section>
    </main>
</body>
</html>