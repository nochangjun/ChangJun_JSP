<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.Vector" %>
<%@ page import="project.RestaurantBean, project.RestaurantMgr,project.RestaurantLikeBean" %>
<jsp:useBean id="BookmarkMgr" class="project.BookmarkMgr"/>
<jsp:useBean id="ReviewMgr" class="project.ReviewMgr"/>
<jsp:useBean id="rstLikeMgr" class="project.RestaurantLikeMgr"/>
<%
// 전달받은 필터 파라미터: 테마(tag)와 단일 지역(region)
    String tag = request.getParameter("tag") != null ? request.getParameter("tag") : "";
    String region = request.getParameter("region") != null ? request.getParameter("region") : "";
    
    String sort = request.getParameter("sort") != null ? request.getParameter("sort") : "popular";
    // "전체" 태그이면 필터 초기화
    if(tag.equals("전체")) {
        tag = "";
        region = "";
    }
    
    // 페이징 처리
    int currentPage = 1;
    if(request.getParameter("page") != null) {
        try {
            currentPage = Integer.parseInt(request.getParameter("page"));
        } catch(Exception e) {
            currentPage = 1;
        }
    }
    int pageSize = 12;
    int offset = (currentPage - 1) * pageSize;
    
    RestaurantMgr mgr = new RestaurantMgr();
 // 필터 조건 적용 맛집 리스트 조회 (정렬 옵션 추가)
    Vector<RestaurantBean> vlist = mgr.getRestaurantList(offset, pageSize, tag, region, sort);
    // 필터 조건에 맞는 총 개수 조회s
    int totalCount = mgr.getTotalCount(tag, region);
    int totalPages = (int)Math.ceil((double)totalCount / pageSize);
    
    // 페이징 블록 (예: 5개씩 표시)
    int blockSize = 5;
    int blockNum = (currentPage - 1) / blockSize;
    int blockStart = blockNum * blockSize + 1;
    int blockEnd = blockStart + blockSize - 1;
    if(blockEnd > totalPages) { blockEnd = totalPages; }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>YUMMY JEJU - 맛집 검색</title>
  <!-- Google Fonts -->
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">
  <!-- Font Awesome -->
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <!-- 네이버 지도 API -->
  <script type="text/javascript" src="https://oapi.map.naver.com/openapi/v3/maps.js?ncpKeyId=s2uzi3murw"></script>
  <!-- 커스텀 CSS -->
  <link rel="stylesheet" href="../css/rst_Find.css">
</head>
<body>
<%@ include file="../header.jsp" %>

<div class="page-title">
  <div class="container-fluid">
    <h1><i class="fas fa-utensils"></i> 제주 맛집 찾기</h1>
    <p class="result-count"><%=totalCount%>개의 맛집이 기다리고 있어요!</p>
  </div>
</div>

<!-- 태그 필터 영역 -->
<div class="tag-filter fade-in">
  <!-- 테마 태그 영역 -->
  <div class="tag-section">
    <h2><i class="fas fa-tags"></i> 음식 카테고리</h2>
    <div class="tag-list" id="themeTags">
      <span class="tag <%=tag.isEmpty() ? "active" : ""%>" data-tag="전체">
        <i class="fas fa-globe"></i> 전체
      </span>
      <span class="tag <%="맛있는제주만들기".equals(tag) ? "active" : ""%>" data-tag="맛있는제주만들기">
        #맛있는제주만들기
      </span>
      <span class="tag <%="착한가격업소".equals(tag) ? "active" : ""%>" data-tag="착한가격업소">
        #착한가격업소
      </span>
      <span class="tag <%="럭셔리트래블인제주".equals(tag) ? "active" : ""%>" data-tag="럭셔리트래블인제주">
        #럭셔리트래블인제주
      </span>
      <span class="tag <%="우수관광사업체".equals(tag) ? "active" : ""%>" data-tag="우수관광사업체">
        #우수관광사업체
      </span>
      <span class="tag <%="무장애관광".equals(tag) ? "active" : ""%>" data-tag="무장애관광">
        #무장애관광
      </span>
      <span class="tag <%="안전여행스탬프".equals(tag) ? "active" : ""%>" data-tag="안전여행스탬프">
        #안전여행스탬프
      </span>
      <span class="tag <%="향토음식".equals(tag) ? "active" : ""%>" data-tag="향토음식">
        #향토음식
      </span>
      <span class="tag <%="한식".equals(tag) ? "active" : ""%>" data-tag="한식">
        #한식
      </span>
      <span class="tag <%="중식".equals(tag) ? "active" : ""%>" data-tag="중식">
        #중식
      </span>
      <span class="tag <%="일식".equals(tag) ? "active" : ""%>" data-tag="일식">
        #일식
      </span>
      <span class="tag <%="카페".equals(tag) ? "active" : ""%>" data-tag="카페">
        #카페
      </span>
      <span class="tag <%="버거".equals(tag) ? "active" : ""%>" data-tag="버거">
        #버거
      </span>
      <span class="tag <%="몸국".equals(tag) ? "active" : ""%>" data-tag="몸국">
        #몸국
      </span>
      <span class="tag <%="해장국".equals(tag) ? "active" : ""%>" data-tag="해장국">
        #해장국
      </span>
      <span class="tag <%="흑돼지".equals(tag) ? "active" : ""%>" data-tag="흑돼지">
        #흑돼지
      </span>
      <span class="tag <%="갈치국".equals(tag) ? "active" : ""%>" data-tag="갈치국">
        #갈치국
      </span>
      <span class="tag <%="고기국수".equals(tag) ? "active" : ""%>" data-tag="고기국수">
        #고기국수
      </span>
      <span class="tag <%="옥돔구이".equals(tag) ? "active" : ""%>" data-tag="옥돔구이">
        #옥돔구이
      </span>
      <span class="tag <%="성게미역국".equals(tag) ? "active" : ""%>" data-tag="성게미역국">
        #성게 미역국
      </span>
      <span class="tag <%="빙떡".equals(tag) ? "active" : ""%>" data-tag="빙떡">
        #빙떡
      </span>
    </div>
  </div>
  
  <!-- 지역 태그 영역 -->
  <div class="tag-section">
    <div class="regionTagContainer">
      <div class="regionTagHeader" onclick="toggleRegion()">
        <span><i class="fas fa-map-marker-alt"></i> 지역별 태그 검색</span> <span class="arrow">▾</span>
      </div>
      <div class="regionTagBody" id="regionTagBody" style="display: none;">
        <div class="tag-list" id="regionTags">
          <span class="tag <%="제주시".equals(region) ? "active" : ""%>" data-region="제주시">
            <i class="fas fa-city"></i> 제주시
          </span>
          <span class="tag <%="서귀포시".equals(region) ? "active" : ""%>" data-region="서귀포시">
            <i class="fas fa-mountain"></i> 서귀포시
          </span>
          <span class="tag <%="섬 속의 섬".equals(region) ? "active" : ""%>" data-region="섬 속의 섬">
            <i class="fas fa-water"></i> 섬 속의 섬
          </span>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- 메인 컨테이너: 맛집 리스트와 지도 -->
<div id="container" class="fade-in">
  <div id="restaurantList">
    <div class="list-header">
      <div class="list-title">맛집 리스트</div>
      <div class="sort-options">
	  <select id="sortOption" onchange="location.href=this.value">
	    <option value="<%=request.getRequestURI()%>?sort=popular&tag=<%=tag%>&region=<%=region%>&page=1" <%= "popular".equals(sort) ? "selected" : "" %>>인기순</option>
	    <option value="<%=request.getRequestURI()%>?sort=rating&tag=<%=tag%>&region=<%=region%>&page=1" <%= "rating".equals(sort) ? "selected" : "" %>>평점순</option>
	  </select>
	</div>
    </div>
    
    <div id="listItems">
      <%
      for (RestaurantBean rb : vlist) {
                 String contextPath = request.getContextPath();
                 String imgUrl = rb.getResolvedImgPath(contextPath);
                 String allTag = rb.getRst_tag();
                 String[] tagArray = allTag.split("[,\\s]+");
                 StringBuilder tagsWithHash = new StringBuilder();
                 int tagCount = 0;
                 for(String t : tagArray) {
                     t = t.trim();
                     if(!t.isEmpty()){
                         tagCount++;
                         if(tagCount <= 3) {
                             tagsWithHash.append("#").append(t).append(" ");
                         } else {
                             tagsWithHash.append("...");
                             break;
                         }   
                     }
                 }
                 String regionLabel = rb.getRegionLabel() != null ? rb.getRegionLabel() : "";
                 String region2Label = rb.getRegion2Label() != null ? rb.getRegion2Label() : "";
                 
                 RestaurantLikeBean likeBean = new RestaurantLikeBean();
                 likeBean.setMember_id((String)session.getAttribute("idKey"));
                 likeBean.setRst_id(rb.getRst_id());
                 boolean isLiked = rstLikeMgr.likedCheck(likeBean);
      %>
      <div class="restaurant-item"
           data-lat="<%= rb.getRst_lat() %>"
           data-long="<%= rb.getRst_long() %>"
           data-img="<%= imgUrl %>"
           data-rst-id="<%= rb.getRst_id() %>">
        <div class="thumbnail">
          <% if(imgUrl != null && !imgUrl.trim().isEmpty()) { %>
            <img src="<%= imgUrl %>" alt="<%= rb.getRst_name() %> 썸네일">
          <% } else { %>
            <img src="<%= contextPath %>/img/photoready.png" alt="사진 준비중">
          <% } %>
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
          <p class="tags"><%= tagsWithHash.toString().trim() %></p>
          <div class="actions">
            <span class="like"><img src="<%= isLiked ? "../img/liked.png" : "../img/like.png" %>"  alt="좋아요"
            onclick="toggleRstLike(<%= rb.getRst_id() %>, this)"
						        class="like-img"> <span class="like-count"><%= rb.getRst_like() %></span></span>
            <span class="review"><img src="../img/review.png" alt="리뷰"> <%=ReviewMgr.ReviewCount(rb.getRst_id()) %></span>
            <span class="favorite"><img src="../img/jjim.png" alt="찜"><%= BookmarkMgr.countBookmark(rb.getRst_id()) %></span>
          </div>
        </div>
      </div>
      <% } %>
    </div>
    
    <!-- 페이징 컨트롤 -->
    <div id="pagination">
		<!-- 첫 페이지 -->
		<% if(currentPage > 1) { %>
		  <a class="first arrow" href="<%= request.getRequestURI() %>?page=1&tag=<%= tag %>&region=<%= region %>" title="첫 페이지">&laquo;</a>
		<% } else { %>
		  <span class="first arrow disabled">&laquo;</span>
		<% } %>
		
		<!-- 이전 페이지 -->
		<% if(currentPage > 1) { %>
		  <a class="prev arrow" href="<%= request.getRequestURI() %>?page=<%= currentPage - 1 %>&tag=<%= tag %>&region=<%= region %>"  title="이전 페이지">&lsaquo;</a>
		<% } else { %>
		  <span class="prev arrow disabled">&lsaquo;</span>
		<% } %>
		
		<!-- 페이지 번호 반복 -->
		<% for(int i = blockStart; i <= blockEnd; i++) {
		     if(i == currentPage) { %>
		    <span class="current"><%= i %></span>
		<%   } else { %>
		    <a href="<%= request.getRequestURI() %>?page=<%= i %>&tag=<%= tag %>&region=<%= region %>"><%= i %></a>
		<%   } } %>
		
		<!-- 다음 페이지 -->
		<% if(currentPage < totalPages) { %>
		  <a class="next arrow" href="<%= request.getRequestURI() %>?page=<%= currentPage + 1 %>&tag=<%= tag %>&region=<%= region %>" title="다음 페이지">&rsaquo;</a>
		<% } else { %>
		  <span class="next arrow disabled">&rsaquo;</span>
		<% } %>
		
		<!-- 마지막 페이지 -->
		<% if(currentPage < totalPages) { %>
		  <a class="last arrow" href="<%= request.getRequestURI() %>?page=<%= totalPages %>&tag=<%= tag %>&region=<%= region %>"  title="마지막 페이지">&raquo;</a>
		<% } else { %>
		  <span class="last arrow disabled">&raquo;</span>
		<% } %>

    </div>
  </div>
  
  <!-- 네이버 지도 영역 -->
  <div id="map"></div>
</div>

<!-- 맵 로딩 인디케이터 -->
<div id="mapLoading" class="map-loading">
  <div class="spinner"></div>
  <p>지도 로딩 중...</p>
</div>

<!-- JavaScript -->
<script>
  // 네이버 지도 초기화 (제주 중심 좌표)
  var mapOptions = {
    center: new naver.maps.LatLng(33.499621, 126.531188),
    zoom: 10,
    zoomControl: true,
    zoomControlOptions: {
      position: naver.maps.Position.TOP_RIGHT
    }
  };
  
  var map = new naver.maps.Map('map', mapOptions);
  
  // 맵 로딩 완료 시 로딩 인디케이터 숨기기
  naver.maps.Event.once(map, 'init_stylemap', function() {
    document.getElementById('mapLoading').style.display = 'none';
  });
  
  var markers = [];
  var infoWindows = [];
  var currentInfoWindow = null;
  
  function closeCurrentInfoWindow() {
    if (currentInfoWindow) {
      currentInfoWindow.close();
      currentInfoWindow = null;
    }
  }
  
  // 마커 및 인포윈도우 업데이트
  function updateMarkers() {
    // 기존 마커 제거
    markers.forEach(function(marker) { marker.setMap(null); });
    markers = [];
    infoWindows = [];
    
    // 모든 맛집 항목에 대해 마커 생성
    var items = document.getElementsByClassName("restaurant-item");
    for (let i = 0; i < items.length; i++) {
      let lat = parseFloat(items[i].getAttribute("data-lat"));
      let lng = parseFloat(items[i].getAttribute("data-long"));
      let title = items[i].querySelector("h3").innerText.trim();
      let imgUrl = items[i].getAttribute("data-img");
      let rstId = items[i].getAttribute("data-rst-id");
      let imgSrc = (imgUrl && imgUrl.trim() !== "") ? imgUrl : "../img/photoready.png";
      
      // 인포윈도우 내용 생성
      let contentString = 
        '<div class="info-window" style="width:250px; position:relative; padding-bottom:15px;">' +
        '  <div class="close-btn" style="position:absolute; top:10px; right:10px; cursor:pointer; z-index:10;" onclick="closeCurrentInfoWindow()">✕</div>' +
        '  <div style="text-align:center; margin:10px 0;">' +
        '    <img src="' + imgSrc + '" alt="' + title + '" style="width:230px; height:150px; object-fit:cover; border-radius:8px;">' +
        '  </div>' +
        '  <div style="margin-top:12px; text-align:center; font-weight:bold; font-size:16px;">' + title + '</div>' +
        '  <div style="margin-top:15px; text-align:center;">' +
        '    <a href="rst_Detail.jsp?rst_id=' + rstId + '" style="display:inline-block; padding:8px 15px; background:linear-gradient(to right, #ff7700, #ff9e44); color:white; text-decoration:none; border-radius:20px; font-weight:500;" onclick="event.stopPropagation();">자세히 보기</a>' +
        '  </div>' +
        '</div>';
      
      // 인포윈도우 생성
      let infoWindow = new naver.maps.InfoWindow({
        content: contentString,
        backgroundColor: "#fff",
        borderColor: "#eee",
        borderWidth: 1,
        borderRadius: "10px",
        pixelOffset: new naver.maps.Point(0, -10)
      });
      
      // 마커 생성
      let marker = new naver.maps.Marker({
        position: new naver.maps.LatLng(lat, lng),
        map: map,
        title: title,
        icon: {
          content: '<div style="width:40px;height:40px;background:url(\'../img/marker.png\') no-repeat;background-size:contain;"></div>',
          size: new naver.maps.Size(40, 40),
          anchor: new naver.maps.Point(20, 40)
        },
        animation: naver.maps.Animation.DROP
      });
      
      // 마커 클릭 이벤트
      naver.maps.Event.addListener(marker, "click", function(e) {
        closeCurrentInfoWindow();
        currentInfoWindow = infoWindow;
        infoWindow.open(map, marker);
      });
      
      // 배열에 추가
      markers.push(marker);
      infoWindows.push(infoWindow);
    }
  }
  
  // 초기 마커 생성
  updateMarkers();
  
  // 리스트 항목 마우스 오버 시 지도 이동 및 InfoWindow 표시
  var restaurantItems = document.getElementsByClassName("restaurant-item");
  for (let i = 0; i < restaurantItems.length; i++) {
    restaurantItems[i].addEventListener("mouseover", function() {
      let lat = parseFloat(this.getAttribute("data-lat"));
      let lng = parseFloat(this.getAttribute("data-long"));
      map.panTo(new naver.maps.LatLng(lat, lng));
      closeCurrentInfoWindow();
      currentInfoWindow = infoWindows[i];
      currentInfoWindow.open(map, markers[i]);
    });
  }
  
  // 테마 태그 필터 이벤트 처리
  document.querySelectorAll("#themeTags .tag").forEach(function(el) {
    el.addEventListener("click", function() {
      var clickedTag = this.getAttribute("data-tag");
      var newTag = (clickedTag === "전체") ? "" : clickedTag;
      window.location.href = window.location.pathname + "?tag=" + encodeURIComponent(newTag) + "&region=" + encodeURIComponent("<%= region %>");
    });
  });
  
  // 지역 태그 토글 및 이벤트 처리
  function toggleRegion() {
    var bodyDiv = document.getElementById('regionTagBody');
    var arrow = document.querySelector('.regionTagHeader .arrow');
    if (bodyDiv.style.display === 'none' || bodyDiv.style.display === '') {
      bodyDiv.style.display = 'block';
      arrow.textContent = '▴';
    } else {
      bodyDiv.style.display = 'none';
      arrow.textContent = '▾';
    }
  }
  
  // 지역 태그 이벤트 설정
  function setupRegionTagEvents() {
    var regionTags = document.querySelectorAll('#regionTags .tag');
    regionTags.forEach(function(tag) {
      tag.addEventListener('click', function() {
        var regionValue = this.getAttribute('data-region');
        var newRegion = this.classList.contains('active') ? "" : regionValue;
        window.location.href = window.location.pathname + "?tag=" + encodeURIComponent("<%= tag %>") + "&region=" + encodeURIComponent(newRegion);
      });
    });
  }
  
  // 페이지 로드 시 지역 태그 이벤트 설정
  document.addEventListener('DOMContentLoaded', function() {
    setupRegionTagEvents();
    
    // 페이드인 애니메이션 효과
    var fadeElements = document.querySelectorAll('.fade-in');
    fadeElements.forEach(function(el) {
      el.classList.add('active');
    });
  });
  
  function toggleRstLike(rst_id, imgElement) {
	    fetch("/myapp/project/rst/Restaurant_LikeToggleServlet?rst_id=" + rst_id)
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

<jsp:include page="../footer.jsp"/>
</body>
</html>