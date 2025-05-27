<%@page import="project.InquiryMgr"%>
<%@page import="project.AdminCourseMgr"%>
<%@page import="project.ReviewMgr"%>
<%@page import="project.RestaurantMgr"%>
<%@page import="project.BookmarkMgr"%>
<%@page contentType="text/html; charset=UTF-8"%>
<jsp:useBean id="memberMgr" class="project.MemberMgr" />
<jsp:useBean id="memberBean" class="project.MemberBean" />
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>나의 맛집</title>
<link rel="stylesheet" href="../css/my_Page.css">
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
	<jsp:include page="../header.jsp" />
	<!-- 스코프 클래스 추가 -->
	<div class="my-page-wrapper">
		<h1>나의 맛집</h1>
		<%
		String loginId = (String) session.getAttribute("idKey");
		memberBean = memberMgr.getMember(loginId);
		%>
		<div class="profile-section">
			<div class="profile-img">
				<%
				String profileImg = memberBean.getMember_image();
				boolean isExternalUrl = profileImg != null && (profileImg.startsWith("http://") || profileImg.startsWith("https://"));
				if (profileImg == null || profileImg.trim().isEmpty()) {
				%>
				<img id="profile-image" src="../img/구머링.png" alt="프로필 이미지">
				<%
				} else if (isExternalUrl) {
				%>
				<img id="profile-image" src="<%=profileImg%>" alt="프로필 이미지">
				<%
				} else {
				%>
				<img id="profile-image"
					src="<%=request.getContextPath() + "/upload/profile/" + profileImg%>"
					alt="프로필 이미지">
				<%
				}
				%>
				<%
				BookmarkMgr bookmarkMgr1 = new BookmarkMgr();
				RestaurantMgr rstMgr1 = new RestaurantMgr();
				ReviewMgr reviewMgr1 = new ReviewMgr();
				AdminCourseMgr courseMgr1 = new AdminCourseMgr();
				InquiryMgr inquiryMgr1 = new InquiryMgr();

				int bookmarkCount = bookmarkMgr1.getBookmarkCountByMember(loginId);
				int courseCount = courseMgr1.getBookmarkCourseCountByMember(loginId);
				int reviewCount = reviewMgr1.ReviewCount(loginId);
				int inquiryCount = inquiryMgr1.getInquiryCountByMember(loginId);
				%>
			</div>
			<div class="stats-section">
				<div class="section-title">
					<i class="fas fa-user-circle"></i>
					<%=memberBean.getMember_nickname()%>님의 제주여행
				</div>
				<div class="stats-grid">
					<div class="stats-item">
						<div>
							<i class="fas fa-heart"></i> 찜한 맛집
						</div>
						<span><%=bookmarkCount%></span>
					</div>
					<div class="stats-item">
						<div>
							<i class="fas fa-map-marked-alt"></i> 찜한 코스
						</div>
						<span><%=courseCount%></span>
					</div>
					<div class="stats-item">
						<div>
							<i class="fas fa-comment-dots"></i> 나의 리뷰
						</div>
						<span><%=reviewCount%></span>
					</div>
					<div class="stats-item">
						<div>
							<i class="fas fa-question-circle"></i> 나의 문의
						</div>
						<span><%=inquiryCount%></span>
					</div>
				</div>
			</div>
		</div>

		<div class="favorite-section">
			<h2>
				<i class="fas fa-history" style="margin-right: 7px"></i> 나의 활동 기록 <small>내가 찜한 맛집과
					코스, 작성한 리뷰와 문의글을 한눈에 확인해보세요</small>
			</h2>
			<div class="tabs">
				<div class="tab active" data-type="bookmark">
					<i class="fas fa-heart"></i> 찜한 맛집 <span>(<%=bookmarkCount%>)
					</span>
				</div>
				<div class="tab" data-type="course">
					<i class="fas fa-map-marked-alt"></i> 찜한 코스 <span>(<%=courseCount%>)
					</span>
				</div>
				<div class="tab" data-type="review">
					<i class="fas fa-comment-dots"></i> 나의 리뷰 <span>(<%=reviewCount%>)
					</span>
				</div>
				<div class="tab" data-type="inquiry">
					<i class="fas fa-question-circle"></i> 나의 문의 <span>(<%=inquiryCount%>)
					</span>
				</div>
			</div>
			<div class="data-content" id="dataContentArea">
				<!-- AJAX 내용 들어감 -->
				<div class="loading-spinner">
					<i class="fas fa-spinner fa-pulse fa-3x"></i>
				</div>
			</div>
			<div class="pagination" id="paginationArea"></div>
		</div>
	</div>
	<jsp:include page="../footer.jsp" />

	<script>
const contextPath2 = "<%=request.getContextPath()%>";

  function loadMyPageTab(type, page) {
    const contentArea = document.getElementById("dataContentArea");
    
    // 로딩 스피너 표시
    contentArea.innerHTML = '<div class="loading-spinner"><i class="fas fa-spinner fa-pulse fa-3x"></i></div>';
    
    const url = contextPath2 + "/project/my/my_Data.jsp?type=" + type + "&page=" + page;

    fetch(url)
      .then(res => res.text())
      .then(html => {
        contentArea.innerHTML = html;

        // 선택된 탭 유지
        const tabs = document.querySelectorAll(".tab");
        tabs.forEach(tab => {
          tab.classList.toggle("active", tab.dataset.type === type);
        });
      })
      .catch(error => {
        contentArea.innerHTML = '<div class="empty-notice"><i class="fas fa-exclamation-circle"></i>데이터를 불러오는 중 오류가 발생했습니다.</div>';
        console.error('Error loading tab content:', error);
      });
  }

  document.addEventListener('DOMContentLoaded', function() {
    // 탭 클릭 이벤트 설정
    const tabs = document.querySelectorAll('.my-page-wrapper .tab');
    tabs.forEach(tab => {
      tab.addEventListener('click', function() {
        const type = this.dataset.type;
        loadMyPageTab(type, 1); // 첫 페이지로 로드
      });
    });
    
    // dataContentArea에 이벤트 위임: 페이지 버튼 클릭 이벤트 처리
    document.getElementById('dataContentArea').addEventListener('click', function(e) {
      const target = e.target.closest('.page-btn');
      if (target) {
        // 현재 활성화된 탭의 타입 획득
        const type = document.querySelector('.my-page-wrapper .tab.active').dataset.type;
        const page = parseInt(target.dataset.page);
        loadMyPageTab(type, page);
        
        // 페이지 상단으로 부드럽게 스크롤
        document.querySelector('.my-page-wrapper .favorite-section').scrollIntoView({ behavior: 'smooth' });
      }
    });

    // 기본값: 찜한 맛집 탭 로드
    loadMyPageTab('bookmark', 1);
  });
</script>
</body>
</html>