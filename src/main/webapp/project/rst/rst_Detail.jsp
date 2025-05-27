<%@page import="project.MemberBean"%>
<%@page import="project.ReviewBean"%>
<%@page import="java.io.Console"%>
<%@page import="project.MenuBean"%>
<%@page import="java.util.Vector"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="project.RestaurantBean, project.RestaurantMgr, project.ReviewLikeBean" %>
<jsp:useBean id="menuBean" class="project.MenuBean"/>
<jsp:useBean id="menuMgr" class="project.MenuMgr"/>
<jsp:useBean id="reviewBean" class="project.ReviewBean"/>
<jsp:useBean id="reviewMgr" class="project.ReviewMgr"/>
<jsp:useBean id="memberMgr" class="project.MemberMgr"/>
<jsp:useBean id="likeMgr" class="project.ReviewLikeMgr"/>
<jsp:useBean id="bookmarkMgr" class="project.BookmarkMgr"/>

<%
	String idKey = (String) session.getAttribute("idKey");
	boolean isLoggedIn = (idKey != null);

    // URL에서 맛집 고유 ID를 가져옴
    String rstIdParam = request.getParameter("rst_id");
    int rst_id = 0; 
    rst_id = Integer.parseInt(rstIdParam);
    
    // DB에서 맛집 상세 정보를 가져옴
    RestaurantMgr mgr = new RestaurantMgr();
    RestaurantBean RstBean = mgr.getRestaurantDetail(rst_id);
    
    // 북마크 체크
    boolean isBookmark = bookmarkMgr.checkBookmark((String)session.getAttribute("idKey"), rst_id);
    
    // 리뷰아이디 - 이 가게에 대한 리뷰를 썻는지 판단
    int myReviewId = 0;
	myReviewId = reviewMgr.searchReviewId(String.valueOf(rst_id), (String)session.getAttribute("idKey"));
    int reviewCount = reviewMgr.ReviewCount(rst_id);
    //리뷰 정렬
    String sort = request.getParameter("sort");
    if (sort == null) {
        sort = "latest"; // 기본 정렬: 최신순
    }
    
    // 페이징 처리
    int totalReviews = reviewMgr.ReviewCount(rst_id); // 전체 리뷰 수
    int pageSize = 5; // 한 페이지당 리뷰 수
    int totalPage = (int)Math.ceil((double)totalReviews / pageSize); // 전체 페이지 수

    String pageParam = request.getParameter("page");
    int currentPage = 1;
    if (pageParam != null) {
        try {
            currentPage = Integer.parseInt(pageParam);
        } catch (NumberFormatException e) {
            currentPage = 1;
        }
    }
    int start = (currentPage - 1) * pageSize;
    
    Vector<ReviewBean> reviews = reviewMgr.searchReview(rst_id, sort, start, pageSize);
    
	 // 로그인 url 넘겨줄때 필요한거
    String currentURL = request.getRequestURI();
    String query = request.getQueryString();
    if (query != null) {
        currentURL += "?" + query;
    }
    String encodedURL = java.net.URLEncoder.encode(currentURL, "UTF-8");
    
    String imgPath = RstBean.getImgpath();
    if (imgPath != null && !imgPath.trim().isEmpty()) {
        if (!imgPath.startsWith("http")) {
            imgPath = request.getContextPath() + "/" + imgPath;
        }
    } else {
        imgPath = request.getContextPath() + "/img/photoready.png";
    }
	
    double rating = RstBean.getRst_rating(); //평점
    int roundedRating = (int)Math.round(rating); // 반올림해서 정수로 (예: 4.3 -> 4)
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= RstBean.getRst_name() %> - YUMMY JEJU</title>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" type="text/css" href="../css/rst_Detail.css">
    
</head>
<body>
<jsp:include page="../header.jsp" />
    
    <!-- 대표 이미지 영역 -->
    <div class="main-image-container">
        <img src="<%= imgPath %>" alt="음식점 대표 이미지" class="main-image">

    </div>

    <div class="content-wrapper">
        <div class="restaurant-info">
            <div class="restaurant-header">
                <div class="restaurant-icon">YJ</div>
                <div>
                    <h2><%= RstBean.getRst_name() %></h2>
                    <%-- 평점은 실제 DB나 계산 결과에 따라 동적으로 출력하도록 수정 가능 --%>
                    <div class="restaurant-stars">
					    <% for (int i = 1; i <= 5; i++) { %>
					        <span class="review-stars"><%= (i <= roundedRating) ? "★" : "☆" %></span>
					    <% } %>
					    <span class="numeric-score" style="margin-left: 5px;"><%= rating %></span>
					</div>
                </div>
                
                <div style="margin-left: auto;" class="bookmark-container">
				    <button 
				        id="bookmarkBtn"
				        class="like-btn" 
				        style="background: none; border: none; font-size: 24px; cursor: pointer;"
				        onclick="toggleBookmark(<%= rst_id %>)">
				        <span id="bookmarkIcon"><%= isBookmark ? "❤️" : "🤍" %></span>
				    </button>
				</div>
            </div>

            <div class="stats">
                <div class="stat-item">
                    <div class="stat-number" id="bookmarkCount"><%= bookmarkMgr.countBookmark(rst_id) %></div>

                    <div class="stat-label">찜</div>
                </div> 
                <div class="stat-item">
                    <%-- 리뷰 수는 DB 집계 또는 별도 조회로 가져와야 함, 하드코딩 예시 --%>
                    <div class="stat-number"><%=reviewCount %></div>
                    <div class="stat-label">리뷰</div>
                </div>
            </div>

            <div>
                <p>📍 <%= RstBean.getRst_address() %></p>
                <%-- 영업시간, 전화번호 등은 DB 정보가 있을 경우 동적으로 출력하도록 수정 --%>
                <p>⏰ 매일 10:00-22:00</p>
                <p>☎️ <%= RstBean.getRst_phonenumber() %></p>
                <p>💬 <%= RstBean.getRst_introduction() %></p>
            </div>
        </div>
		<% Vector<MenuBean> vlist = menuMgr.getMenuList(rst_id); %>
	    <div class="menu-info">
	    <h3>대표 메뉴</h3>
		    <div id="menu-list">
		        <% for (int i = 0; i < vlist.size(); i++) {
		            MenuBean menu = vlist.get(i);
		        %>
		        <div class="rst_menu-item" >
		            <div class="menu-item-header">
		                <h4><%= menu.getMenu_name() %></h4>
		                <div class="menu-item-price"><%= menu.getMenu_price() %></div>
		            </div>
		            <% if (menu.getMenu_contents() != null) { %>
		                <p><%= menu.getMenu_contents() %></p>
		            <% } %>
		            <% if (menu.getMenu_image() != null && !menu.getMenu_image().isEmpty()) { %>
		                <img src="<%= menu.getMenu_image() %>" alt="<%= menu.getMenu_name() %>"
		                     style="width: 100px; height: 100px; object-fit: cover; border-radius: 5px; margin-top: 10px;">
		            <% } %>
		        </div>
		        <% } %>
		    </div>


		<%
		    //int totalReviews = reviewMgr.ReviewCount(rst_id);
			 int[] ratingCounts = new int[5];
			    for (int i = 1; i <= 5; i++) {
			        ratingCounts[i - 1] = reviewMgr.ReviewRatingCount(rst_id, i);
			    }
		%>
        <div class="rating-section">
            <div class="rating-header">
                <h3>평점과 리뷰</h3>
            </div>
            <div class="rating-content">
                <div class="rating-bar-container">
				    <%
				        for (int i = 5; i >= 1; i--) {
				        	 int count = ratingCounts[i - 1]; // i점에 해당하는 리뷰 수
				                int percent = 0;
				                if (totalReviews > 0) {
				                    percent = (int)(((double)count / totalReviews) * 100); // 퍼센트 계산
				                }
				    %>
				        <div class="rating-bar-wrapper">
				            <span class="rating-label"><%= i %></span>
				            <div class="rating-bar">
				                <div class="rating-fill" style="width: <%= percent %>%"></div>
				            </div>
				            <span class="rating-info"> <%= percent %>%</span>
				        </div>
				    <%
				        }
				    %>
				</div>
                
                <div class="rating-score-container">
                    <div class="rating-score"><%=RstBean.getRst_rating() %></div>
                    <div class="rating-count">(리뷰 <%=reviewCount %>개)</div>
                </div>
            </div>
        </div>
		
		<div class="review-header-container">
			    <!-- 기존 form 방식 정렬 버튼 -> AJAX 함수 호출로 변경 -->
				<div class="review-buttons">
				    <button class="review-button <%= "latest".equals(sort) ? "active" : "" %>" onclick="loadReviews('latest')">최신순</button>
				    <button class="review-button <%= "high".equals(sort) ? "active" : "" %>" onclick="loadReviews('high')">별점 높은순</button>
				    <button class="review-button <%= "low".equals(sort) ? "active" : "" %>" onclick="loadReviews('low')">별점 낮은순</button>
				</div>

			    <% if (rstIdParam != null) { %>
				    <% if (myReviewId == 0) { %>
				        <button class="write-review-button" onclick="goToReviewWrite(<%= rst_id %>)">리뷰 작성</button>
				    <% } else { %>
				        <button class="write-review-button" disabled >리뷰 작성</button>
				    <% } %>
				<% } else { %>
				    <button class="write-review-button" onclick="alert('로그인이 필요합니다.')">리뷰 작성</button>
				<% } %>
			</div>
		
        <div id="review-container" class="review-section">
            <%-- 리뷰 목록은 별도 DB 조회 후 동적으로 출력하도록 수정 --%>
            <% for (ReviewBean review : reviews) {  
            	MemberBean mBean = new MemberBean();
            	mBean = memberMgr.getMember(review.getMember_id());
            	
            	boolean isLiked = false;
                if (mBean.getMember_id() != null) {
                    ReviewLikeBean likeBean = new ReviewLikeBean();
                    likeBean.setMember_id((String) session.getAttribute("idKey"));
                    likeBean.setReview_id(review.getReview_id());
                    isLiked = likeMgr.searchLike(likeBean); // 좋아요 이미 눌렀으면 true
                }
            	
            %>
			    <div class="review-card">
			        <div class="review-header">
			            <div class="reviewer-info">
			                <div class="reviewer-avatar">
							    <%
								    String profileImg = mBean.getMember_image(); 
								    boolean isExternalUrl = profileImg != null && (profileImg.startsWith("http://") || profileImg.startsWith("https://"));
								%>
								
								<% if (profileImg == null || profileImg.trim().isEmpty()) { %>
								    <img src="../img/구머링.png" class="reviewer-profile-img">
								<% } else if (isExternalUrl) { %>
								    <img src="<%= profileImg %>" class="reviewer-profile-img">
								<% } else { %>
								    <img src="<%= request.getContextPath() + "/upload/profile/" + profileImg %>" class="reviewer-profile-img">
								<% } %>
							</div>
			                <div>
			                    <div><%= mBean.getMember_name()%></div>
			                    <div style="font-size: 12px; color: #777;">
			                        리뷰 <%= reviewMgr.ReviewCount(review.getMember_id()) %> 
			                    </div>
			                </div>
			            </div>
			            <!-- 신고 아이콘 (본인 댓글이 아닌 경우만 표시) -->
                         <%
						    String loginId = (String) session.getAttribute("idKey");
						    boolean showReport = (loginId != null) && !loginId.equals(review.getMember_id());
						%>
						<% if (showReport) { %>
						    <div class="report-dropdown">
						        <img src="../img/report.png" alt="신고" class="report-icon" onclick="showReportMenu('review', <%= review.getReview_id() %>)">
						        <div class="review-dropdown-content" id="report-menu-review-<%= review.getReview_id() %>">
						            <a class="report-reason" onclick="showReportForm('review', <%= review.getReview_id() %>, '불건전한 내용')">불건전한 내용</a>
						            <a class="report-reason" onclick="showReportForm('review', <%= review.getReview_id() %>, '욕설/비방')">욕설/비방</a>
						            <a class="report-reason" onclick="showReportForm('review', <%= review.getReview_id() %>, '광고/홍보')">광고/홍보</a>
						            <a class="report-reason" onclick="showReportForm('review', <%= review.getReview_id() %>, '개인정보 노출')">개인정보 노출</a>
						            <a class="report-reason" onclick="showReportForm('review', <%= review.getReview_id() %>, '기타')">기타</a>
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
				    <% 
				        } 
				    %>
			
			        <div class="review-stars">
			            <% for (int i = 1; i <= 5; i++) { %>
			                <%= (i <= review.getReview_rating()) ? "★" : "☆" %>
			            <% } %>
			        </div>
			
			        <div class="review-content">
			            <p><%= review.getReview_comment()%></p>
			        </div>
			
			        <%-- 리뷰 이미지 출력 (이미지가 여러 개일 경우 반복 처리) --%>
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
						        onclick="toggleLike(<%= review.getReview_id() %>, this)"
						        class="like-img"
						    >
						    <span class="like-count"><%= review.getReview_like() %></span>
						</div>
					    <div><%= review.getReview_create_at() %></div>
					</div>
				</div>
			<% } %>
			        
            <!-- 페이징 처리 UI -->
			<div class="pagination">
			    <% for (int i = 1; i <= totalPage; i++) { %>
			        <a href="rst_Detail.jsp?rst_id=<%= rst_id %>&sort=<%= sort %>&page=<%= i %>" class="page-link <%= (i == currentPage) ? "active" : "" %>">
			            <%= i %>
			        </a>
			    <% } %>
			</div>
        </div>
    </div>
    

	
	<!-- 페이지 마지막 쯤에 한 번만 작성 -->
	<div class="report-form-overlay" id="report-form-overlay" style="display:none;">
	    <div class="report-form-container">
	        <div class="report-form-title">신고하기</div>
	        <form action="../support/support_Board_Report_Process.jsp" method="post" class="report-form" id="report-form">
	            <input type="hidden" name="action" value="report">
	            <input type="hidden" name="reportType" id="report-type">
	            <input type="hidden" name="targetId" id="report-target-id">
	            <input type="hidden" name="boardId" id="report-board-id">
	            <input type="hidden" name="returnUrl" value="<%= java.net.URLEncoder.encode(request.getRequestURL() + "?" + request.getQueryString(), "UTF-8") %>">
	            
	            <textarea name="reason" id="report-reason" placeholder="신고 사유를 입력하세요..." required></textarea>
	            <div class="report-form-buttons">
	                <button type="button" class="report-cancel" onclick="hideReportForm()">취소</button>
	                <button type="submit" class="report-submit">신고</button>
	            </div>
	        </form>
	    </div>
	</div>
	
	
<%@ include file="../footer.jsp" %>

<script>
function toggleLike(reviewId, imgElement) {
    fetch("/myapp/project/rst/LikeToggleServlet?review_id=" + reviewId)
        .then(response => {
            if (!response.ok) throw new Error("서버 응답 오류");
            return response.json();
        })
        .then(data => {
            if (data.success) {
                // ✅ 이미지 변경
                imgElement.src = data.liked ? "../img/liked.png" : "../img/like.png";

                // ✅ 좋아요 수만 변경
                const likeCountEl = imgElement.parentElement.querySelector(".like-count");
                if (likeCountEl) {
                    likeCountEl.textContent = data.newLikeCount;
                }
            } else {
            	document.getElementById("yummy-loginAlertModal").style.display = "flex";

            }
        })
        .catch(error => {
            console.error("에러 발생:", error);
        });
}

function showReportMenu(type, targetId) {
    var reportMenuId = 'report-menu-' + type + '-' + targetId;
    var reportMenu = document.getElementById(reportMenuId);
    if (reportMenu) {
        // 다른 모든 메뉴 닫기
        var allMenus = document.querySelectorAll('.report-dropdown-content');
        for (var i = 0; i < allMenus.length; i++) {
            if (allMenus[i] !== reportMenu) {
                allMenus[i].style.display = 'none';
            }
        }
        
        // 선택된 메뉴 토글
        reportMenu.style.display = reportMenu.style.display === 'block' ? 'none' : 'block';
    }
}

//신고 폼 표시
function showReportForm(type, targetId, reason) {
    // 신고 대상 정보 설정
    document.getElementById('report-type').value = type;
    document.getElementById('report-target-id').value = targetId;
    document.getElementById('report-reason').value = reason;

    // 신고 메뉴 닫기
    var allMenus = document.querySelectorAll('.report-dropdown-content');
    for (var i = 0; i < allMenus.length; i++) {
        allMenus[i].style.display = 'none';
    }

    // 신고 폼 표시
    var overlay = document.getElementById('report-form-overlay');
    overlay.style.display = 'flex';
}

// 신고 폼 숨기기
function hideReportForm() {
    var overlay = document.getElementById('report-form-overlay');
    overlay.style.display = 'none';
}

function goToReviewWrite(rst_id) {
    const isLoggedIn = <%= isLoggedIn %>;

    if (!isLoggedIn) {
    	document.getElementById("yummy-loginAlertModal").style.display = "flex";
    } else {
        location.href = "rst_review_Write.jsp?rst_id=" + rst_id;
    }
}

function toggleBookmark(rstId) {
    fetch("<%= request.getContextPath() %>/project/RstBookmarkServlet", {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: 'rst_id=' + encodeURIComponent(rstId)

    })
    .then(response => {
        if (!response.ok) throw new Error("서버 응답 오류");
        return response.json();
    })
    .then(data => {
        if (data.success) {
            const icon = document.getElementById('bookmarkIcon');
            const count = document.getElementById('bookmarkCount');
            icon.textContent = data.bookmarked ? '❤️' : '🤍';
            count.textContent = data.bookmarkCount;
        } else {
        	document.getElementById("yummy-loginAlertModal").style.display = "flex";
        }
    })
    .catch(error => {
        console.error("에러 발생:", error);
        alert("문제가 발생했습니다.");
    });
}

function loadReviews(sortType) {
    const rstId = <%= rst_id %>;
    const contextPath = "<%= request.getContextPath() %>";
    const url = contextPath + "/project/rst/load_reviews.jsp?rst_id=" + rstId + "&sort=" + sortType;

    // ⭐ 정렬 버튼 클래스 토글 처리
    document.querySelectorAll(".review-button").forEach(btn => {
        btn.classList.remove("active");
    });
    const buttonMap = {
        latest: "최신순",
        high: "별점 높은순",
        low: "별점 낮은순"
    };
    document.querySelectorAll(".review-button").forEach(btn => {
        if (btn.textContent.trim() === buttonMap[sortType]) {
            btn.classList.add("active");
        }
    });

    // 리뷰 내용 로딩
    fetch(url)
        .then(response => response.text())
        .then(html => {
            document.getElementById("review-container").innerHTML = html;

            // 이벤트 재바인딩
            rebindReviewEvents();
        });
}

function rebindReviewEvents() {
    // 좋아요
    document.querySelectorAll(".like-img").forEach(img => {
        img.onclick = function () {
            const reviewId = this.dataset.reviewId;
            toggleLike(reviewId, this);
        };
    });

    // 신고
    document.querySelectorAll(".report-icon").forEach(icon => {
        icon.onclick = function () {
            const reviewId = this.dataset.reviewId;
            showReportMenu("review", reviewId);
        };
    });

    // 신고 사유
    document.querySelectorAll(".report-reason").forEach(reason => {
        reason.onclick = function () {
            const reviewId = this.dataset.reviewId;
            const reasonText = this.textContent;
            showReportForm("review", reviewId, reasonText);
        };
    });
}

//로그인 페이지로 이동
function goToLogin() {
  const currentUrl = window.location.pathname + window.location.search;
  const encodedUrl = encodeURIComponent(currentUrl);

  window.location.href = "<%=request.getContextPath()%>/project/login/login.jsp?url=" + encodedUrl;
}

// 로그인 경고 모달 닫기
function closeLoginModal() {
    document.getElementById("yummy-loginAlertModal").style.display = "none";
}
</script>
</body>
<footer>
</footer>
</html>
