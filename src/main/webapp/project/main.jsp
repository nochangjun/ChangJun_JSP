<%@page import="java.util.List"%>
<%@page import="project.EventBean"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<jsp:useBean id="rstMgr" class="project.RestaurantMgr" />
<jsp:useBean id="eventMgr" class="project.EventMgr" />
<%
List<EventBean> eventList = eventMgr.getRecentEvents(3); // 최근 이벤트 3개 불러오기
eventMgr.updateEventStatuses(); // 상태 업데이트
%>
<%
    String msg = (String) session.getAttribute("storeSuccessMsg");
    if (msg != null) {
%>
    <script>
        alert("<%= msg %>");
    </script>
<%
        session.removeAttribute("storeSuccessMsg"); // ✅ 한 번만 출력되게 제거
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="css/main.css">
<link
	href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap"
	rel="stylesheet">
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<link rel="stylesheet"
	href="https://cdn.jsdelivr.net/npm/swiper/swiper-bundle.min.css" />
<title>YUMMY JEJU</title>
<!-- CSS는 main.css로 분리되었습니다 -->
</head>
<body>
	<jsp:include page="header.jsp" />

	<!-- Hero 영역을 Swiper로 변경 -->
	<div class="hero">
		<!-- Swiper 컨테이너 -->
		<div class="swiper">
			<!-- 슬라이드 래퍼 -->
			<div class="swiper-wrapper">
				<!-- 각 슬라이드는 .swiper-slide 클래스를 사용 -->
				<div class="swiper-slide">
					<img src="img/main.png" alt="제주도 풍경">
				</div>
				<div class="swiper-slide">
					<img src="img/main2.png" alt="제주도 풍경2">
				</div>
				<div class="swiper-slide">
					<img src="img/main3.png" alt="제주도 풍경3">
				</div>
				<div class="swiper-slide">
					<img src="img/main4.png" alt="제주도 풍경4">
				</div>
				<div class="swiper-slide">
					<img src="img/main5.png" alt="제주도 풍경5">
				</div>
			</div>
			<!-- 옵션: 페이지네이션 등 추가할 수 있음 -->
			<div class="swiper-pagination"></div>
		</div>

		<!-- Swiper 위에 오버레이 형태로 텍스트와 검색박스 등을 배치하는 경우 -->
		<div class="hero-content">
			<h1 class="hero-title">YUMMY JEJU</h1>
			<p class="hero-subtitle">제주도의 특별한 맛을 찾아서</p>
			<div class="search-box">
				<form action="search_Result.jsp" method="get" class="search-form"
					onsubmit="return validateSearch();">
					<input type="text" id="keywordInput" name="keyword"
						placeholder="맛집을 검색하세요">
					<button type="submit">
						<i class="fas fa-search"></i>
					</button>
				</form>

				<script type="text/javascript">
				    function validateSearch() {
				        var keyword = document.getElementById("keywordInput").value;
				        if (keyword.trim() === "") {
				            alert("검색어를 입력하세요");
				            return false; // 검색어가 없으면 폼 제출 중단
				        }
				        return true; // 검색어가 있으면 폼 제출
				    }
				</script>
			</div>
		</div>
	</div>

	<!-- Main Content -->
	<div class="container">
		<!-- Featured Restaurants -->
		<div class="section-header fade-in">
			<h2 class="section-title">
				<i class="fas fa-utensils"></i> 제주 인기 맛집
			</h2>
		</div>
		<div class="section-card fade-in delay-1">
			<div class="food-grid">
				<div class="food-item" onclick="location.href='rst/rst_Find.jsp?tag=흑돼지'">
					<div class="food-img-container">
						<img src="img/제주 흑돼지.png" alt="제주 흑돼지">
						<div class="food-overlay">
							<p>제주 흑돼지</p>
						</div>
					</div>
				</div>
				<div class="food-item" onclick="location.href='rst/rst_Find.jsp?tag=해산물'">
					<div class="food-img-container">
						<img src="img/해산물요리.png" alt="해산물 요리">
						<div class="food-overlay">
							<p>해산물 요리</p>
						</div>
					</div>
				</div>
				<div class="food-item" onclick="location.href='rst/rst_Find.jsp?tag=감귤'">
					<div class="food-img-container">
						<img src="img/감귤.PNG" alt="대표 음식">
						<div class="food-overlay">
							<p>제주 감귤</p>
						</div>
					</div>
				</div>
				<div class="food-item" onclick="location.href='rst/rst_Find.jsp?tag=카페'">
					<div class="food-img-container">
						<img src="img/카페디저트.jpg" alt="카페 디저트">
						<div class="food-overlay">
							<p>카페 디저트</p>
						</div>
					</div>
				</div>
			</div>
		</div>

		<!-- Location-based Restaurants -->
		<div class="section-header fade-in delay-2">
			<h2 class="section-title">
				<i class="fas fa-map-marker-alt"></i> 지역별 추천 맛집
			</h2>
		</div>
		<div class="section-card fade-in delay-3">
			<div class="map-section">
				<div class="map-container">
					<!-- 제주도 지도 -->
					<img src="img/main_map.png" alt="제주도 지도">
				</div>
				<div class="location-list">
					<div class="location-item"
						onclick="location.href='rst/rst_Find.jsp'">
						<span><i class="fas fa-globe-asia"></i> 전체</span> <span
							class="location-count"><%=rstMgr.RSTCountRegion("")%>곳</span>
					</div>
					<div class="location-item"
						onclick="location.href='rst/rst_Find.jsp?region=제주시'">
						<span><i class="fas fa-city"></i> 제주시</span> <span
							class="location-count"><%=rstMgr.RSTCountRegion("제주시")%>곳</span>
					</div>
					<div class="location-item"
						onclick="location.href='rst/rst_Find.jsp?region=서귀포시'">
						<span><i class="fas fa-mountain"></i> 서귀포시</span> <span
							class="location-count"><%=rstMgr.RSTCountRegion("서귀포시")%>곳</span>
					</div>
					<div class="location-item"
						onclick="location.href='rst/rst_Find.jsp?region=섬 속의 섬'">
						<span><i class="fas fa-water"></i> 섬 속의 섬</span> <span
							class="location-count"><%=rstMgr.RSTCountRegion("섬 속의 섬")%>곳</span>
					</div>
				</div>
			</div>
		</div>

		<!-- Events -->
		<div class="event-banner fade-in delay-4"
			onclick="location.href='event/event.jsp'">
			<i class="fas fa-gift"></i> EVENT <i class="fas fa-gift"></i>
		</div>

		<div class="event-grid fade-in delay-4">
			<%
			for (EventBean eBean : eventList) {
				String imageUrl = eBean.getImageUrl();
				boolean isExternal = imageUrl != null && (imageUrl.startsWith("http://") || imageUrl.startsWith("https://"));
				String imagePath = (imageUrl != null && !imageUrl.trim().isEmpty())
				? (isExternal ? imageUrl : request.getContextPath() + "/" + imageUrl)
				: request.getContextPath() + "/img/default_event.png";

				String title = eBean.getTitle() != null ? eBean.getTitle() : "제목 없음";
				String startDate = eBean.getStartDate() != null ? eBean.getStartDate() : "시작일 미정";
				String endDate = eBean.getEndDate() != null ? eBean.getEndDate() : "종료일 미정";
			%>
			<div class="event-item">
				<div class="event-img-container">
					<img src="<%=imagePath%>" alt="<%=title%>">
				</div>
				<div class="event-content">
					<p><%=title%></p>
					<div class="event-date"><%=startDate%>
						~
						<%=endDate%></div>
					<a href="event/event_Detail.jsp?event_id=<%=eBean.getEventId()%>"
						class="view-more"> 자세히 보기 <i class="fas fa-chevron-right"></i>
					</a>
				</div>
			</div>
			<%
			}
			%>
		</div>

		<jsp:include page="footer.jsp" />
		<script src="https://cdn.jsdelivr.net/npm/swiper/swiper-bundle.min.js"></script>
		<script>
		    document.addEventListener('DOMContentLoaded', function() {
		        var swiper = new Swiper('.swiper', {
		        	slidesPerView: 1,          // ✅ 하나만 보이게
		        	  centeredSlides: false,      // ✅ 가운데 정렬
		        	  loop: true,
		        	  spaceBetween: 0,
		        	  autoplay: {
		        	    delay: 6000,
		        	    disableOnInteraction: false,
		        	  },
		        	  pagination: {
		        	    el: '.swiper-pagination',
		        	    clickable: true,
		        	  },
		        });
		    });
		</script>
</body>
</html>