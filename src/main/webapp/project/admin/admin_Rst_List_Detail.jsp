<%@page import="project.ReviewBean"%>
<%@page import="java.util.Vector"%>
<%@page import="project.ReviewMgr"%>
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="project.RestaurantMgr, project.RestaurantBean" %>
<%
    request.setCharacterEncoding("UTF-8");

    String rstIdParam = request.getParameter("rst_id");
    if (rstIdParam == null || rstIdParam.trim().isEmpty()) {
        out.println("<script>alert('유효하지 않은 요청입니다.'); history.back();</script>");
        return;
    }

    int rst_id = Integer.parseInt(rstIdParam);
    RestaurantMgr mgr = new RestaurantMgr();
    RestaurantBean bean = mgr.getRestaurantDetail(rst_id);

    int pageSize = 8;
    String pageNumParam = request.getParameter("page");
    int pageNum = pageNumParam != null ? Integer.parseInt(pageNumParam) : 1;
    int startRow = (pageNum - 1) * pageSize;
    int offset = startRow;
    int endRow = startRow + pageSize;

    ReviewMgr reviewMgr = new ReviewMgr();

    // 리뷰 삭제 처리
    String delId = request.getParameter("delete_id");
    if (delId != null) {
        try {
            int reviewId = Integer.parseInt(delId);
            boolean deleted = reviewMgr.deleteReview(reviewId);
            if (deleted) {
                response.sendRedirect("admin_Rst_List_Detail.jsp?rst_id=" + rst_id + "&page=" + pageNum);
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    int totalCount = reviewMgr.ReviewCount(rst_id);
    int totalPage = (int) Math.ceil((double) totalCount / pageSize);
    int pageBlock = 5;
    int startPage = ((pageNum - 1) / pageBlock) * pageBlock + 1;
    int endPage = startPage + pageBlock - 1;
    if (endPage > totalPage) endPage = totalPage;

    Vector<ReviewBean> reviews = reviewMgr.searchReview(rst_id, "latest", startRow, pageSize);
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>가게 상세정보 - YUMMY JEJU</title>
    <link rel="stylesheet" href="../css/admin_Rst_List_Detail.css">
    <script>
        function deleteReview(reviewId) {
            if (confirm("해당 리뷰를 삭제하시겠습니까?")) {
                location.href = "admin_Rst_List_Detail.jsp?rst_id=<%= rst_id %>&page=<%= pageNum %>&delete_id=" + reviewId;
            }
        }
    </script>
</head>
<body>
    <!-- 사이드바 및 헤더 인클루드 -->
    <%@ include file="../admin_Header.jsp" %>

    <div class="main-content">
        <section class="inquiry-section">
            <h2>가게 상세정보</h2>

            <div class="store-detail">
                <div class="detail-container">
                    <div class="detail-item">
                        <label>가게 이름</label>
                        <div class="detail-value"><%= bean.getRst_name() %></div>
                    </div>
                    <div class="detail-item">
                        <label>연락처</label>
                        <div class="detail-value"><%= bean.getRst_phonenumber() %></div>
                    </div>
                </div>

                <div class="form-group">
                    <label>도로명 주소</label>
                    <input type="text" value="<%= bean.getRst_address() %>" readonly />
                </div>

                <div class="form-group">
                    <label>소개</label>
                    <input type="text" value="<%= bean.getRst_introduction() %>" readonly />
                </div>

                <div class="form-group">
                    <label>태그</label>
                    <input type="text" value="<%= bean.getRst_tag() %>" readonly />
                </div>

                <div class="detail-container">
                    <div class="detail-item">
                        <label>평점</label>
                        <div class="detail-value"><%= bean.getRst_rating() %></div>
                    </div>
                    <div class="detail-item">
                        <label>좋아요</label>
                        <div class="detail-value"><%= bean.getRst_like() %></div>
                    </div>
                    <div class="detail-item">
                        <label>가게 사장 ID</label>
                        <div class="detail-value"><%= bean.getMember_id() %></div>
                    </div>
                </div>

                <div class="store-image-container">
                    <label>대표 이미지</label>
                    <%
                        String imgSrc = bean.getImgpath();
                        if (imgSrc != null && !imgSrc.startsWith("http")) {
                            imgSrc = request.getContextPath() + "/" + imgSrc;
                        }
                    %>
                    <div>
                        <img src="<%= imgSrc %>" alt="대표 이미지" />
                    </div>
                </div>

                <h4>등록된 리뷰</h4>
                <table>
                    <thead>
                        <tr>
                            <th>No</th>
                            <th>리뷰 내용</th>
                            <th>삭제</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if (reviews != null && reviews.size() > 0) {
                                for (int i = 0; i < reviews.size(); i++) {
                                    ReviewBean review = reviews.get(i);
                        %>
                        <tr>
                            <td><%= offset + i + 1 %></td>
                            <td><%= review.getReview_comment() %></td>
                            <td><button class="delete-review-btn" onclick="deleteReview('<%= review.getReview_id() %>')">삭제</button></td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="3">등록된 리뷰가 없습니다.</td>
                        </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
                
                <!-- 페이지 네이션 영역 -->
                <% if (totalPage > 0) { %>
                <div class="pagination">
                    <% if (startPage > 1) { %>
                        <a href="?page=<%= startPage - 1 %>&rst_id=<%= rst_id %>" title="이전">&lsaquo;</a>
                    <% } %>

                    <% for (int i = startPage; i <= endPage; i++) { %>
                        <% if (i == pageNum) { %>
                            <strong><%= i %></strong>
                        <% } else { %>
                            <a href="?page=<%= i %>&rst_id=<%= rst_id %>"><%= i %></a>
                        <% } %>
                    <% } %>

                    <% if (endPage < totalPage) { %>
                        <a href="?page=<%= endPage + 1 %>&rst_id=<%= rst_id %>" title="다음">&rsaquo;</a>
                    <% } %>
                </div>
                <% } %>
                
            
            </div>
        </section>
    </div>
</body>
</html>