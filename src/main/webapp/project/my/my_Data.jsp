<%@page import="project.RestaurantCourseBookmarkMgr"%>
<%@page import="project.InquiryBean"%>
<%@page import="project.AdminCourseBean"%>
<%@page import="project.AdminCourseMgr"%>
<%@page import="project.ReviewBean"%>
<%@page import="project.RestaurantMgr"%>
<%@page import="project.RestaurantBean"%>
<%@page import="java.util.Vector"%>
<%@page import="project.BookmarkMgr, project.ReviewMgr, project.InquiryMgr"%>
<jsp:useBean id="RestaurantMgr" class="project.RestaurantMgr"/>
<%@ page contentType="text/html; charset=UTF-8"%>
<link rel="stylesheet" href="../css/my_Data.css">
<%
    request.setCharacterEncoding("UTF-8");
    String id = (String) session.getAttribute("idKey");
    String type = request.getParameter("type");

    int spage = 1;  // ✅ 선언 추가
    try {
        spage = Integer.parseInt(request.getParameter("page"));  // ✅ 파라미터 파싱
    } catch (Exception e) {
        spage = 1;
    }

    int pageSize = 5;
    int start = (spage - 1) * pageSize;  // ✅ page 기준으로 start 계산

    BookmarkMgr bookmarkMgr = new BookmarkMgr();
    RestaurantMgr rstMgr = new RestaurantMgr();	
    ReviewMgr reviewMgr = new ReviewMgr();
    AdminCourseMgr courseMgr = new AdminCourseMgr();
    InquiryMgr inquiryMgr = new InquiryMgr();
    
    int totalCount = 0;

    if ("bookmark".equals(type)) {
        totalCount = bookmarkMgr.getBookmarkCountByMember(id);
    } else if ("review".equals(type)) {
        totalCount = reviewMgr.ReviewCount(id);
    } else if ("course".equals(type)) {
        totalCount = courseMgr.getBookmarkCourseCountByMember(id);
    } else if ("inquiry".equals(type)) {
        totalCount = inquiryMgr.getInquiryCountByMember(id);
    }

    if ("bookmark".equals(type)) {
        Vector<RestaurantBean> bookmarks = bookmarkMgr.getBookmarksByMember(id, start, pageSize);

        if (bookmarks.size() == 0) {
%>
            <div class="empty-notice">
                <i class="exclamation-mark">!</i>
                <p>찜한 맛집이 없습니다</p>
            </div>
<%
        } else {
%>
            <div class="bookmark-list">
<%
            for (RestaurantBean rb : bookmarks) {
                String imgUrl = rb.getImgpath();
                if (imgUrl == null || imgUrl.trim().isEmpty()) {
                    imgUrl = request.getContextPath() + "/img/photoready.png";
                } else if (!imgUrl.startsWith("http")) {
                    imgUrl = request.getContextPath() + "/" + imgUrl;
                }

                boolean isLiked = false; // 좋아요 여부 확인 로직 추가 가능
                String regionLabel = rb.getRegionLabel();
                String region2Label = rb.getRegion2Label();
%>
                <div class="restaurant-item" onclick="location.href='../rst/rst_Detail.jsp?rst_id=<%= rb.getRst_id() %>'"
                     data-lat="<%= rb.getRst_lat() %>"
                     data-long="<%= rb.getRst_long() %>"
                     data-img="<%= imgUrl %>"
                     data-rst-id="<%= rb.getRst_id() %>">
                    <div class="thumbnail">
                        <img src="<%= imgUrl %>" alt="<%= rb.getRst_name() %> 썸네일">
                    </div>
                    <div class="info">
                        <h3>
                            <a href="rst_Detail.jsp?rst_id=<%= rb.getRst_id() %>" class="restaurant-link">
                                <%= rb.getRst_name() %>
                            </a>
                        </h3>
                        <p class="region">
                            <%= regionLabel %>
                            <% if(!regionLabel.isEmpty() && !region2Label.isEmpty()) { %> &gt; <% } %>
                            <%= region2Label %>
                        </p>
                        <p class="tags"><%= rb.getRst_introduction() %></p>
                        <div class="actions">
                            <span class="like"><img src="<%= isLiked ? "../img/liked.png" : "../img/like.png" %>"  alt="좋아요"
                                onclick="toggleRstLike(<%= rb.getRst_id() %>, this)"
                                class="like-img"> 
                                <span class="like-count"><%= rb.getRst_like()!=null ? rb.getRst_like() : "0"%></span>
                            </span>
                            <span class="review"><img src="../img/review.png" alt="리뷰"> <%= reviewMgr.ReviewCount(rb.getRst_id()) %></span>
                            <span class="favorite"><img src="../img/jjim.png" alt="찜"><%= bookmarkMgr.countBookmark(rb.getRst_id()) %></span>
                        </div>
                    </div>
                </div>
<%
            } // end for
%>
            </div> <!-- /.bookmark-list -->
<%
        }
  /////////////////////////////////////////////////////////// 리뷰 페이지/////////////////////////////////////////////////////
    } else if ("review".equals(type)) {
        Vector<ReviewBean> myReviews = reviewMgr.getReviewsByMember(id, start, pageSize);

        if (myReviews == null || myReviews.size() == 0) {
%>
            <div class="empty-notice">
                <i class="exclamation-mark">!</i>
                <p>작성한 리뷰가 없습니다</p>
            </div>
<%
        } else {
%>
            <div class="review-list">
<% 
for (ReviewBean review : myReviews) { 
	RestaurantBean rstBean = RestaurantMgr.getRestaurantDetail(review.getRst_id());
    String rstName = rstBean.getRst_name();
    double rating = review.getReview_rating();
    String comment = review.getReview_comment();
    String date = review.getReview_create_at();
    Vector<String> images = review.getImgList();
    // 메뉴 태그 처리
    String[] menus = null;
    if (review.getReview_menu() != null && !review.getReview_menu().trim().isEmpty()) {
        menus = review.getReview_menu().split(",");
    }
%>

    <!-- 각 리뷰 하나를 감싸는 카드 -->
    <div class="review-card" onclick="location.href='../rst/rst_Detail.jsp?rst_id=<%= review.getRst_id() %>'">
        <!-- 리뷰 헤더: 리뷰어 정보 + 식당명 & 별점 -->
        <div class="review-header">
            <!-- 식당 정보(이름 + 별점) -->
            <div class="review-title">
                <h3><%= rstName %></h3>
                <div class="review-stars">
                    <% for (int i = 1; i <= 5; i++) { %>
                        <span><%= (i <= rating) ? "★" : "☆" %></span>
                    <% } %>
                </div>
            </div>
        </div> <!-- /.review-header -->

        <!-- 메뉴 태그 -->
        <%
        if (menus != null) {
        %>
            <div class="review-menu-tags">
                <% for (String menu : menus) { %>
                    <span class="menu-tag"><%= menu.trim() %></span>
                <% } %>
            </div>
        <%
        } 
        %>

        <!-- 리뷰 내용 -->
        <div class="review-content">
            <p><%= comment %></p>
        </div>

        <!-- 리뷰 이미지들 -->
        <%
        if (images != null && !images.isEmpty() && images.get(0).trim().length() > 0) {
        %>
            <div class="review-images">
                <% 
                for (String img : images) { 
                    String imageUrl = "";
                    if (img == null || img.trim().isEmpty()) {
                        continue;
                    } else if (img.startsWith("http://") || img.startsWith("https://")) {
                        imageUrl = img;
                    } else {
                        imageUrl = request.getContextPath() + "/" + img;
                    }
                %>
                    <img src="<%= imageUrl %>" alt="리뷰 이미지" class="review-image">
                <% } %>
            </div>
        <%
        } 
        %>

        <!-- 리뷰 푸터 (작성일 등) -->
        <div class="review-actions">
					    <div class="review_like">
						    <img 
						        src="../img/liked.png"
						        onclick="toggleLike(<%= review.getReview_id() %>, this)"
						        class="like-img"
						    >
						    <span class="like-count"><%= review.getReview_like() %></span>
						</div>
					    <div><%= review.getReview_create_at() %></div>
					</div>
    </div> <!-- /.review-card -->

<%
} // end for
%>
</div> <!-- /.review-list -->
<%
        }
	} else if ("course".equals(type)) {
        Vector<AdminCourseBean> courseList = courseMgr.getBookmarkedCoursesByMember(id, start, pageSize);

        if (courseList == null || courseList.size() == 0) {
%>
            <div class="empty-notice">
                <i class="exclamation-mark">!</i>
                <p>찜한 코스가 없습니다</p>
            </div>
<%
        } else {
%>
            <ul class="course-list">
<%
            for (AdminCourseBean bean : courseList) {

            	String imagePath;
            	if (bean.getImagePath() == null || bean.getImagePath().trim().isEmpty()) {
            	    imagePath = "https://cdn.pixabay.com/photo/2017/07/31/20/58/soup-2552622_1280.jpg";
            	} else if (bean.getImagePath().startsWith("http://") || bean.getImagePath().startsWith("https://")) {
            	    // 외부 URL은 그대로 사용
            	    imagePath = bean.getImagePath();
            	} else {
            	    // 업로드된 이미지 등 상대경로일 경우 컨텍스트 경로 추가
            	    imagePath = request.getContextPath() + "/" + bean.getImagePath();
            	}
%>
                <li class="course-item" onclick="location.href='../rst/rst_Day_Course.jsp?id=<%= bean.getCourseId() %>'">
                    <img src="<%= imagePath %>" alt="코스 이미지" />

                    <div class="course-info">
                        <div class="course-title"><%= bean.getCourseTitle() %></div>
                        <div class="course-subtitle"><%= bean.getDescription() %></div>
                    </div>
                </li>
<%
            } // end for
%>
            </ul> <!-- /.course-list -->
<%
        } // end else
    } else if ("inquiry".equals(type)) {
        Vector<InquiryBean> inquiryList = inquiryMgr.getInquiriesByMember(id, start, pageSize);

        if (inquiryList == null || inquiryList.size() == 0) {
    %>
            <div class="empty-notice">
                <i class="exclamation-mark">!</i>
                <p>등록된 문의가 없습니다</p>
            </div>
    <%
        } else {
    %>
        <table class="inq-table">
            <thead>
                <tr>
                    <th width="8%">번호</th>
                    <th width="52%">제목</th>
                    <th width="20%">작성일</th>
                    <th width="20%">상태</th>
                </tr>
            </thead>
            <tbody>
    <%
            for (int i = 0; i < inquiryList.size(); i++) {
                InquiryBean inquiry = inquiryList.get(i);
    %>
                <tr>
                    <td><%= i + 1 %></td>
                    <td style="text-align: left; padding-left: 20px;" onclick="location.href='../support/support_Inquiry_Detail.jsp?id=<%= inquiry.getInq_id() %>'">
                        <%= inquiry.getInq_title() %>
                    </td>
                    <td><%= inquiry.getInq_create_at().toString().substring(0, 10) %></td>
                    <td><%= inquiry.getInq_status() %></td>
                </tr>
    <%
            } // end for
    %>
            </tbody>
        </table>
    <%
        } // end else
    } // end inquiry type
	%>
	
	
	
<%
if(!"inquiry".equals(type)){
int totalPage = (int) Math.ceil((double) totalCount / pageSize);
if (totalPage > 1) {
%>
<div class="pagination" id="paginationArea">
<% for (int i = 1; i <= totalPage; i++) { %>
  <button class="page-btn <%= (i == spage) ? "active" : "" %>" data-page="<%= i %>"><%= i %></button>
<% } %>
</div>
<% }
}%>

