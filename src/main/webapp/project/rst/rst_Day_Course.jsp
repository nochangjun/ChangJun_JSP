<%@page import="project.RestaurantCourseBookmarkMgr"%>
<%@page import="project.LikeMgr"%>
<%@ page contentType="text/html; charset=UTF-8"%>
<%@ page import="project.AdminCourseMgr, project.AdminCourseBean"%>
<%@ page
	import="java.util.*, project.RestaurantMgr, project.RestaurantBean"%>
<%@ page import="org.json.JSONArray, org.json.JSONObject"%>
<%
// 1. 코스 ID 추출
String idParam = request.getParameter("id");
int courseId = (idParam != null) ? Integer.parseInt(idParam) : -1;

// 2. 코스 정보 로딩
AdminCourseMgr courseMgr = new AdminCourseMgr();
AdminCourseBean courseBean = courseMgr.getCourseById(courseId);

// 3. 조회수 증가
courseMgr.incrementCourseWatch(courseId);

// 4. 로그인 여부 및 좋아요 여부 확인
String loginId = (String) session.getAttribute("idKey");
LikeMgr likeMgr = new LikeMgr();

int likeCount = likeMgr.getLikeCount("course", courseId);
boolean isLiked = false;
if (loginId != null) {
	isLiked = likeMgr.hasUserLiked("course", courseId, loginId);
}

RestaurantCourseBookmarkMgr bookmarkMgr = new RestaurantCourseBookmarkMgr();
int bookmarkCount = bookmarkMgr.countCourseBookmark(courseId);
boolean isBookmarked = false;
if (loginId != null) {
	isBookmarked = bookmarkMgr.checkCourseBookmark(loginId, courseId);
}

// 5. 가게 리스트 파싱
List<String> storeNames = new ArrayList<>();
if (courseBean.getStores() != null && !courseBean.getStores().isEmpty()) {
	storeNames = Arrays.asList(courseBean.getStores().replaceAll("\\[|\\]", "").replaceAll("\"", "").split(","));
}

// 6. 가게 정보 로딩 및 마커 데이터 생성
RestaurantMgr rstMgr = new RestaurantMgr();
Map<String, String> storeImageMap = new HashMap<>();
Map<String, RestaurantBean> storeInfoMap = new HashMap<>();
JSONArray markerArray = new JSONArray();
int idx = 1;

for (String store : storeNames) {
	String trimmed = store.trim();
	RestaurantBean rst = rstMgr.getRestaurantByName(trimmed);
	if (rst != null) {
		storeImageMap.put(trimmed, rst.getImgpath()); // 이미지 경로 저장
		storeInfoMap.put(trimmed, rst); // 전체 정보 저장

		JSONObject obj = new JSONObject();
		obj.put("name", trimmed);
		obj.put("lat", rst.getRst_lat());
		obj.put("lng", rst.getRst_long());
		obj.put("index", idx++);
		markerArray.put(obj);
		System.out.println("📌 storeName: " + trimmed);
		System.out.println("📌 storeInfoMap 매핑 결과 rst_id: " + (rst != null ? rst.getRst_id() : "NULL"));
	} else {
		System.out.println("❌ DB에서 가게 못 찾음: " + trimmed);
	}

}
%>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8" />
<title><%=courseBean.getCourseTitle()%></title>
<script type="text/javascript"
	src="https://oapi.map.naver.com/openapi/v3/maps.js?ncpKeyId=s2uzi3murw"></script>
<link rel="stylesheet" href="../css/rst_Day_Course.css" />
</head>
<body>
	<jsp:include page="../header.jsp" />
	<div class="container">
		<!-- 제목과 소제목 (중앙 정렬) -->
		<div class="header">
			<h1><%=courseBean.getCourseTitle()%></h1>
		</div>

		<!-- 좋아요/조회수/북마크/공유영역 - TOP -->
		<div class="top-info-bar">
			<!-- 왼쪽: 좋아요 하트, 조회수 -->
			<div class="left-section">
				<!-- 좋아요 하트 -->
				<%
				String heartImg = isLiked ? "heart.png" : "gg.png"; // 좋아요 여부에 따라 변경
				String heartPath = request.getContextPath() + "/img/" + heartImg;
				%>
				<span class="like-icon-wrap" onclick="toggleLike()"> <img
					id="heartIcon" src="../img/<%=isLiked ? "heart.png" : "gg.png"%>"
					alt="좋아요" class="icon-heart" /> <span id="likeCount"
					class="like-count"><%=likeCount%></span>
				</span> <span class="view-count"> <img src="../img/look.png"
					alt="조회수" class="icon-view" /> <span class="view-number"><%=courseBean.getCourseWatch()%></span>
				</span>
			</div>

			<!-- 오른쪽: 북마크, 공유 + 공유횟수 -->
			<div class="right-section">
				<span class="bookmark-icon-wrap" onclick="toggleBookmark()">
					<img id="bookmarkIcon"
					src="../img/<%=isBookmarked ? "bookmark_filled.png" : "bookmark.png"%>"
					alt="북마크" class="icon-bookmark" /> <span id="bookmarkCount"><%=bookmarkCount%></span>
				</span> <span class="share-icon-wrap" onclick="copyCourseUrl()"> <img
					src="../img/share.png" alt="공유" class="icon-share" />
				</span>
			</div>
		</div>

		<!-- 태그 아이콘 + 텍스트 영역 -->
		<div class="info-section">
			<div class="info-item">
				<img src="../img/tag.png" alt="태그 아이콘" class="info-icon" />
				<div class="info-text">
					<span class="info-label">태그</span> <span class="info-value"><%=courseBean.getCourseTag() != null ? courseBean.getCourseTag() : ""%></span>
				</div>
			</div>
		</div>

		<!-- 네이버 지도가 들어갈 컨테이너 -->
		<div class="map-area" id="map" style="width: 100%; height: 400px;"></div>
		<script>
			  document.addEventListener("DOMContentLoaded", function () {
			    var mapOptions = {
			      center: new naver.maps.LatLng(33.389, 126.545), // 초기 중심(임시)
			      zoom: 10
			    };
			    var map = new naver.maps.Map('map', mapOptions);
			
			    var markers = <%=markerArray.toString()%>;
			    console.log("전체 마커 데이터:", markers);
			
			    var bounds = new naver.maps.LatLngBounds();
			    var path = []; // 선으로 연결할 좌표 저장
			
			    markers.forEach(function(markerInfo) {
			      var position = new naver.maps.LatLng(markerInfo.lat, markerInfo.lng);
			      bounds.extend(position);
			      path.push(position); // ✅ 경로 추가
			
			      // ✅ 번호 + 가게 이름 마커
			      new naver.maps.Marker({
			    	  position: position,
			    	  map: map,
			    	  icon: {
			    	    content:
			    	      '<div style="display:flex;align-items:center;gap:6px;">' +
			    	        '<div style="background:#FF6F61;color:white;border-radius:50%;width:28px;height:28px;line-height:28px;text-align:center;font-weight:bold;font-size:14px;">' +
			    	          markerInfo.index +
			    	        '</div>' +
			    	        '<div style="background:white;border:1px solid #ccc;border-radius:6px;padding:4px 8px;font-size:13px;color:#333;white-space:nowrap;box-shadow:0 1px 4px rgba(0,0,0,0.1);">' +
			    	          markerInfo.name +
			    	        '</div>' +
			    	      '</div>',
			    	    size: new naver.maps.Size(160, 36),
			    	    anchor: new naver.maps.Point(30, 18)
			    	  },
			    	  title: markerInfo.name
			    	});
			      });
			
			    // ✅ 선 연결 (순서대로)
			    new naver.maps.Polyline({
			      map: map,
			      path: path,
			      strokeColor: '#FF6F61',
			      strokeOpacity: 0.9,
			      strokeWeight: 3
			    });
			
			    // ✅ 자동 범위 조정
			    if (!bounds.isEmpty()) {
			      map.fitBounds(bounds);
			    }
			  });
		  </script>

		<!-- Progressbar를 슬라이더 위에 올림 -->
		<ul class="progressbar-slider" id="progressbar"></ul>
			
		<div class="slider-outer-wrapper">
			<!-- ✅ 슬라이더 컨트롤은 여기, wrapper 바깥! -->
			<div class="slider-controls">
				<button class="slider-button" id="prevBtn">&#10094;</button>
				<button class="slider-button" id="nextBtn">&#10095;</button>
			</div>
			
			<!-- 사진 슬라이더 영역 -->
			<div class="slider-container" style="position: relative;">
				<div class="slider-wrapper" id="sliderWrapper">
					<%
					int slideIdx = 1;
					for (String store : storeNames) {
						String trimmed = store.trim();
						String imgPath = storeImageMap.get(trimmed);
						if (imgPath != null && !imgPath.trim().isEmpty()) {
							boolean isExternal = imgPath.startsWith("http://") || imgPath.startsWith("https://");
							String encodedImgPath = imgPath.replace(" ", "%20");
							String fullPath = isExternal ? encodedImgPath : (request.getContextPath() + "/" + encodedImgPath);
					%>
					<div class="slide" data-index="<%=slideIdx%>">
						<img src="<%=fullPath%>" alt="<%=trimmed%>">
					</div>
					<%
							slideIdx++;
						}
					}
					%>
				</div>
			</div>
		</div>

		<!-- 🍽️ 가게 정보 출력 영역 -->
		<div id="storeInfoContainer">
			<%
			int infoIdx = 1;
			for (String store : storeNames) {
				String trimmed = store.trim(); // ⭐ 동일하게 트림 적용
				RestaurantBean rst = storeInfoMap.get(trimmed); // 동일한 키로 접근
				if (rst != null) {
					%>
					<div class="store-info-item" data-index="<%=infoIdx%>"
						style="display: none;">
						<div class="info-number">
							<span class="step-circle"><%=infoIdx%></span> <span
								class="info-name"><%=rst.getRst_name()%></span>
						</div>
						<div class="info-address"><%=rst.getRst_address() != null ? rst.getRst_address() : "주소 없음"%></div>
						<div class="info-introduction"><%=rst.getRst_introduction() != null ? rst.getRst_introduction() : "소개 없음"%></div>
		
						<!-- ✅ 가게 상세 페이지 이동 버튼 -->
						<div class="info-detail-link">
							<a
								href="<%=request.getContextPath()%>/project/rst/rst_Detail.jsp?rst_id=<%=rst.getRst_id()%>"
								class="view-detail-btn"> 가게 정보 보기 → </a>
						</div>
					</div>
					<%
				} else {
					System.out.println("❌ storeInfoMap에서 못 찾음: " + trimmed);
					}
					infoIdx++;
				}
			%>
		</div>
	</div>

	<jsp:include page="../footer.jsp" />
	<script src="../js/rst_Day_Course.js"></script>
	<script>
		document.addEventListener("DOMContentLoaded", function () {
		  const steps = document.querySelectorAll("#progressbar li");
		  const lines = document.querySelectorAll(".step-line");
		  const infos = document.querySelectorAll(".store-info-item");
		  const slides = document.querySelectorAll(".slide");
		  const sliderWrapper = document.getElementById("sliderWrapper");
		  const progressbar = document.getElementById("progressbar");
		  const sliderContainer = document.querySelector('.slider-container');
		
		  const slideWidth = slides[0].offsetWidth + parseInt(getComputedStyle(slides[0]).marginRight || 0);
		  const progressbarItems = [];
		
		  slides.forEach((slide, i) => {
		    const li = document.createElement("li");
		    li.textContent = i + 1; // 순서대로 숫자
		    li.setAttribute("data-index", i);
		    li.classList.add("progress-step");
		
		    li.style.width = "36px";
		    li.style.height = "36px";
		    li.style.borderRadius = "50%";
		    li.style.border = "3px solid #ddd";
		    li.style.background = "#fff";
		    li.style.textAlign = "center";
		    li.style.lineHeight = "36px";
		    li.style.margin = "0 5px";
		    li.style.fontWeight = "bold";
		    li.style.cursor = "pointer";
		
		    progressbar.appendChild(li);
		    progressbarItems.push({ type: 'li', element: li });
		
		    if (i < slides.length - 1) {
		      const stepLine = document.createElement("div");
		      stepLine.className = "step-line";
		      progressbar.appendChild(stepLine);
		      progressbarItems.push({ type: 'line', element: stepLine });
		    }
		
		    li.addEventListener("click", () => {
		    	console.log("Clicked progress li:", i); // ← 이거 넣어보세요
		      activateUpTo(i);
		    });
		    
		    slide.addEventListener("click", () => {
	    	  activateUpTo(i);
	    	});
		  });
		  
		  requestAnimationFrame(() => {
			  // progressbar-slider의 width 설정
			  let totalProgressbarWidth = 0;
			  progressbarItems.forEach(item => {
				  	const el = item.element;
				    const style = window.getComputedStyle(el);
				    const width = parseFloat(style.width);
				    const marginLeft = parseFloat(style.marginLeft);
				    const marginRight = parseFloat(style.marginRight);
				    totalProgressbarWidth += width + marginLeft + marginRight;
				  });
				  progressbar.style.width = totalProgressbarWidth + 'px';
		  });
		  
		  let currentIndex = 0;
		  const maxIndex = slides.length - 1;
		  
		  function updateSliderTransform() {
			  sliderWrapper.style.transform = `translateX(-${currentIndex * slideWidth}px)`;
		  }
		  
		  document.getElementById("prevBtn").addEventListener("click", () => {
		    if (currentIndex > 0) {
		    	currentIndex--;
		        activateUpTo(currentIndex);
		        updateSliderTransform();
		    }
		  });

		  document.getElementById("nextBtn").addEventListener("click", () => {
			  if (currentIndex < maxIndex) {
				    currentIndex++;
				    activateUpTo(currentIndex);
				    updateSliderTransform();
			  }
		  });
		  
		  let isInitialLoad = true;
		  
		  function activateUpTo(index) {
			currentIndex = index; // 현재 인덱스 갱신
		    let stepIndex = 0;
		
		    progressbarItems.forEach((item) => {
		      if (item.type === 'li') {
		        item.element.style.borderColor = stepIndex <= index ? "#ff5555" : "#ddd";
		        item.element.style.color = stepIndex <= index ? "#ff5555" : "#ddd";
		        stepIndex++;
		      } else if (item.type === 'line') {
		        item.element.classList.toggle("active", stepIndex - 1 < index);
		      }
		    });
		
		    infos.forEach((info) => {
		      info.style.display = parseInt(info.dataset.index) === index + 1 ? "block" : "none";
		    });
		
		    slides.forEach((slide) => {
		      slide.classList.remove("active");
		    });
		
		    const currentSlide = slides[index];
		    if (currentSlide) {
		      currentSlide.classList.add("active");
		      
		   	  // ⛔ 새로고침 시 scrollIntoView 방지
		      if (!isInitialLoad) {
			   	  // 자연스럽게 해당 슬라이드가 보이게 스크롤 이동
			      currentSlide.scrollIntoView({
			        behavior: "smooth",
			        inline: "center", // 또는 "start" = 왼쪽 정렬
			        block: "nearest"
			      });
		      }
		    }
		  }
		
		  window.toggleBookmark = function() {
		    const userId = "<%=loginId%>";
		    if (!userId) {
		      document.getElementById("yummy-loginAlertModal").style.display = "flex";
		      return;
		    }
		
		    const courseId = <%=courseId%>;
		    fetch('<%=request.getContextPath()%>/project/RstCourseBookmarkServlet', {
		      method: "POST",
		      headers: {
		        "Content-Type": "application/x-www-form-urlencoded"
		      },
		      body: "course_id=" + courseId
		    })
		    .then(res => res.json())
		    .then(data => {
		      if (data.success) {
		        const icon = document.getElementById("bookmarkIcon");
		        const count = document.getElementById("bookmarkCount");
		        icon.src = data.coursebookmarked ? "../img/bookmark_filled.png" : "../img/bookmark.png";
		        count.textContent = data.coursebookmarkCount;
		      } else {
		        document.getElementById("yummy-loginAlertModal").style.display = "flex";
		      }
		    })
		    .catch(err => {
		      console.error("북마크 요청 실패:", err);
		      alert("서버 오류");
		    });
		  }
		
		  window.toggleLike = function() {
		    const userId = "<%=loginId%>";
		    if (!userId) {
		      document.getElementById("yummy-loginAlertModal").style.display = "flex";
		      return;
		    }
		
		    const heartIcon = document.getElementById("heartIcon");
		    const likeCount = document.getElementById("likeCount");
		    const courseId = <%=courseId%>;
		
		    fetch("<%=request.getContextPath()%>/LikeToggleServlets", {
		      method: "POST",
		      headers: { "Content-Type": "application/x-www-form-urlencoded" },
		      body: "likeType=course&targetId=" + courseId
		    })
		    .then(res => res.json())
		    .then(data => {
		      if (data.success) {
		        heartIcon.src = data.liked ? "../img/heart.png" : "../img/gg.png";
		        likeCount.textContent = data.likeCount;
		      } else {
		        document.getElementById("yummy-loginAlertModal").style.display = "flex";
		      }
		    })
		    .catch(err => {
		      console.error("요청 실패:", err);
		      alert("서버 오류");
		    });
		  }
		
		  window.copyCourseUrl = function () {
			  const url = window.location.href;

			  // modern clipboard API 사용 가능한 경우
			  if (navigator.clipboard && window.isSecureContext) {
			    navigator.clipboard.writeText(url).then(() => {
			      alert("링크가 클립보드에 복사되었습니다!");
			    }).catch(err => {
			      console.error("클립보드 복사 실패:", err);
			      alert("복사에 실패했습니다.");
			    });
			  } else {
			    // fallback 방식 (비 HTTPS 또는 구형 브라우저용)
			    const textArea = document.createElement("textarea");
			    textArea.value = url;
			    document.body.appendChild(textArea);
			    textArea.select();

			    try {
			      const successful = document.execCommand('copy');
			      if (successful) {
			        alert("링크가 클립보드에 복사되었습니다!");
			      } else {
			        alert("복사에 실패했습니다.");
			      }
			    } catch (err) {
			      console.error("execCommand 복사 실패:", err);
			      alert("복사에 실패했습니다.");
			    }

			    document.body.removeChild(textArea);
			  }
			}

		
		  function goToLogin() {
		    const currentUrl = window.location.pathname + window.location.search;
		    const encodedUrl = encodeURIComponent(currentUrl);
		    window.location.href = "<%=request.getContextPath()%>/project/login/login.jsp?url=" + encodedUrl;
		  }
		
		  function closeLoginModal() {
		    document.getElementById("yummy-loginAlertModal").style.display = "none";
		  }
		
		  const totalSlideWidth = slides.length * slideWidth;
		  const containerWidth = sliderContainer.offsetWidth;

		  if (totalSlideWidth < containerWidth) {
		    sliderWrapper.style.justifyContent = "center";
		  } else {
		    sliderWrapper.style.justifyContent = "flex-start";
		  }
		  
		  activateUpTo(0); // 초기 상태
		  isInitialLoad = false;
		});
	</script>

</body>
</html>

