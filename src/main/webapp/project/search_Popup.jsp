<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/project/css/search_Popup.css">

<!-- 검색 팝업 오버레이 -->
<div id="searchPopup" class="search-popup">
	<div class="search-popup-content">
		<button class="close-button" onclick="closeSearchPopup()">✕</button>
	
		<div class="search-header">
			<h1 style="font-size: 28px; font-weight: bold; color: #FF8A3D; margin-right: 30px;">YUMMY JEJU</h1>
			<form class="search-form" action="${pageContext.request.contextPath}/project/search_Result.jsp" method="get" style="flex: 1;">
				<div class="search-input-container" style="width: 100%;">
				    <input type="text" class="search-input" name="keyword" placeholder="검색어를 입력하세요">
				    <button class="search-button" type="submit">
				        <img src="${pageContext.request.contextPath}/project/img/돋보기.png" alt="검색">
				    </button>
				</div>
			</form>
		</div>

		<div class="search-tags">
		    <span class="tag" onclick="setSearchTerm('제주')">#제주</span>
		    <span class="tag" onclick="setSearchTerm('애월')">#애월</span>
		    <span class="tag" onclick="setSearchTerm('대표음식')">#대표음식</span>
		    <span class="tag" onclick="setSearchTerm('흑돼지')">#흑돼지</span>
		    <span class="tag" onclick="setSearchTerm('카페')">#카페</span>
		</div>

		<div class="recent-searches">
			<div class="recent-searches-header">
				<h3>최근 검색어</h3>
				<button class="delete-all" onclick="clearAllSearchTerms()">
					전체 삭제 <img src="${pageContext.request.contextPath}/project/img/휴지통.png" alt="삭제">
				</button>
			</div>
			<div class="search-terms">
				<!-- 최근 검색어는 자바스크립트로 동적으로 추가 -->
			</div>
		</div>
	</div>
</div>

<script src="${pageContext.request.contextPath}/project/js/search_Popup.js"></script>