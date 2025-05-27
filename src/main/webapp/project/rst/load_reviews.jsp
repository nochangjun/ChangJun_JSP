<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page pageEncoding="UTF-8"%>
<%@ page import="java.util.*, project.ReviewBean, project.ReviewMgr, project.MemberBean, project.MemberMgr, project.ReviewLikeMgr, project.ReviewLikeBean" %>

<%
    request.setCharacterEncoding("UTF-8");

    String rstIdParam = request.getParameter("rst_id");
    String sort = request.getParameter("sort");
    String idKey = (String) session.getAttribute("idKey");

    int rst_id = 0;
    if (rstIdParam != null && !rstIdParam.trim().isEmpty()) {
        rst_id = Integer.parseInt(rstIdParam);
    } else {
        out.println("<div style='color:red;'>❗ 잘못된 요청입니다. rst_id 없음</div>");
        return;
    }

    if (sort == null) sort = "latest";

    ReviewMgr reviewMgr = new ReviewMgr();
    MemberMgr memberMgr = new MemberMgr();
    ReviewLikeMgr likeMgr = new ReviewLikeMgr();

    Vector<ReviewBean> reviews = reviewMgr.searchReview(rst_id, sort, 0, 5); // 기본 5개만
%>

<!-- 리뷰 리스트 출력 -->
<% for (ReviewBean review : reviews) {
    MemberBean mBean = memberMgr.getMember(review.getMember_id());

    boolean isLiked = false;
    if (idKey != null) {
        ReviewLikeBean likeBean = new ReviewLikeBean();
        likeBean.setMember_id(idKey);
        likeBean.setReview_id(review.getReview_id());
        isLiked = likeMgr.searchLike(likeBean);
    }
%>
    <div class="review-card">
        <div class="review-header">
            <div class="reviewer-info">
                <div class="reviewer-avatar">
                    <% 
					    String profileImg = mBean.getMember_image();
					    if (profileImg == null || profileImg.trim().isEmpty()) {
					%>
					    <img src="../img/구머링.png" class="reviewer-profile-img">
					<%
					    } else if(profileImg.startsWith("http")) {  // 외부 URL이면 그대로 사용
					%>
					    <img src="<%= profileImg %>" class="reviewer-profile-img">
					<%
					    } else {  // 그 외에는 내부 서버 파일 경로와 결합
					%>
					    <img src="<%= request.getContextPath() + "/upload/profile/" + profileImg %>" class="reviewer-profile-img">
					<%
					    }
					%>
                </div>
                <div>
                    <div><%= mBean.getMember_nickname() %></div>
                    
                    <div style="font-size: 12px; color: #777;">
                        리뷰 <%= reviewMgr.ReviewCount(review.getMember_id()) %> 
                    </div>
                </div>
            </div>
            
             <%
            String loginId = (String) session.getAttribute("idKey");
            boolean showReport = (loginId != null) && !loginId.equals(review.getMember_id());
        %>
        
        
        <% if (showReport) { %>
            <div class="report-dropdown">
                <img src="../img/report.png" alt="신고" class="report-icon" data-review-id="<%= review.getReview_id() %>">
                <div class="review-dropdown-content" id="report-menu-review-<%= review.getReview_id() %>">
                    <a class="report-reason" data-review-id="<%= review.getReview_id() %>">불건전한 내용</a>
                    <a class="report-reason" data-review-id="<%= review.getReview_id() %>">욕설/비방</a>
                    <a class="report-reason" data-review-id="<%= review.getReview_id() %>">광고/홍보</a>
                    <a class="report-reason" data-review-id="<%= review.getReview_id() %>">개인정보 노출</a>
                    <a class="report-reason" data-review-id="<%= review.getReview_id() %>">기타</a>
                </div>
            </div>
        <% } %>
        </div>
        
       

        <% 
            String menuStr = review.getReview_menu(); 
            if (menuStr != null && !menuStr.trim().isEmpty()) {
                String[] menus = menuStr.split(",");
        %>
            <div class="review-menu-tags">
                <% for (String menu : menus) { %>
                    <span class="menu-tag"><%= menu.trim() %></span>
                <% } %>
            </div>
        <% } %>

        <div class="review-stars">
            <% for (int i = 1; i <= 5; i++) { %>
                <%= (i <= review.getReview_rating()) ? "★" : "☆" %>
            <% } %>
        </div>

        <div class="review-content">
            <p><%= review.getReview_comment() %></p>
        </div>

        <% 
            Vector<String> images = review.getImgList();
            if (images != null && !images.isEmpty() && images.get(0).trim().length() > 0) {
        %>
            <div class="review-images">
                <% for (String img : images) { %>
                    <img src="<%= request.getContextPath() + "/" + img %>" alt="리뷰 이미지" class="review-image">
                <% } %>
            </div>
        <% } %>

        <div class="review-actions">
            <div class="review_like">
                <img 
                    src="<%= isLiked ? "../img/liked.png" : "../img/like.png" %>" 
                    class="like-img" data-review-id="<%= review.getReview_id() %>">
                <span class="like-count"><%= review.getReview_like() %></span>
            </div>
            <div><%= review.getReview_create_at() %></div>
        </div>

        
    </div>
<% } %>
