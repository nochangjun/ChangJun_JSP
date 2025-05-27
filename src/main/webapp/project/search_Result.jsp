<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.Vector" %>
<%@ page import="project.RestaurantBean, project.MenuBean, project.RestaurantMgr, project.MenuMgr" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>검색결과</title>
    <!-- CSS 경로는 프로젝트 경로에 맞춰 수정하세요 -->
    <link rel="stylesheet" href="<%=request.getContextPath()%>/project/css/search_Result.css">
</head>
<body>
<jsp:include page="header.jsp"/>
<%
	//1) 인코딩 및 파라미터
	request.setCharacterEncoding("UTF-8");
	String keyword  = request.getParameter("keyword");
	if (keyword == null || keyword.trim().isEmpty()) {
	    out.print("검색어를 입력해주세요.");
	    return;
	}
	String category = request.getParameter("category");
	if (category == null || category.trim().isEmpty()) {
	    category = "restaurant";
	}
	
	// 2) 페이징 변수 설정
	int currentPage = 1;
	try {
	    currentPage = Integer.parseInt(request.getParameter("page"));
	    if (currentPage < 1) currentPage = 1;
	} catch (Exception e) { /* 기본 1페이지 */ }
	int pageSize = 10;                          // 한 페이지당 10개
	int offset   = (currentPage - 1) * pageSize; 
	
	 // 3) 매니저 및 전체 개수 조회
    RestaurantMgr rstMgr  = new RestaurantMgr();
    MenuMgr       menuMgr = new MenuMgr();
    int rstTotalCount     = rstMgr.countSearchRestaurants(keyword);
    int menuTotalCount    = menuMgr.countSearchMenus(keyword);

    // ← 이 두 줄을 꼭 추가!
    int rstCount  = rstTotalCount;
    int menuCount = menuTotalCount;

    // 4) 페이지별 리스트 조회
    Vector<RestaurantBean> rstList = new Vector<>();
    Vector<MenuBean>       menuList = new Vector<>();
    if ("restaurant".equals(category)) {
        rstList  = rstMgr.searchRestaurants(keyword, offset, pageSize);
    } else {
        menuList = menuMgr.searchMenus(keyword, offset, pageSize);
    }
	// 5) 전체 페이지 수 및 블록 계산
	int totalCount = "restaurant".equals(category) ? rstTotalCount : menuTotalCount;
	int totalPages = (int)Math.ceil((double)totalCount / pageSize);
	
	int blockSize  = 5;
	int blockNum   = (currentPage - 1) / blockSize;
	int blockStart = blockNum * blockSize + 1;
	int blockEnd   = blockStart + blockSize - 1;
	if (blockEnd > totalPages) blockEnd = totalPages;
    
	
	

%>

<div class="container"><!-- 왼쪽 정렬을 위한 컨테이너 -->
    <!-- 검색결과 영역 -->
    <div class="search-top">
        <!-- 제목 왼쪽 정렬 -->
        <h1 class="search-title">검색결과</h1>
        <!-- 구분선 표시 -->
        <hr class="divider" />
        <!-- 예) “고기” 검색결과 n건 -->
        <p class="search-info">
            <span class="keyword"><%= keyword %></span> 검색결과 
            <span class="count"><%= totalCount %>건</span>
        </p>
    </div>
    
    <!-- 탭 메뉴 (맛집 / 메뉴) - 중앙 정렬 -->
    <div class="tab-area">
        <ul class="tab-menu">
            <li <%= ("restaurant".equals(category) ? "class='active'" : "") %>>
                <a href="search_Result.jsp?keyword=<%= java.net.URLEncoder.encode(keyword, "UTF-8") %>&category=restaurant">
                    맛집 (<%= rstCount %>)
                </a>
            </li>
            <%
                // “고기” 검색시 메뉴 탭을 완전히 숨기고 싶다면 if(!keyword.equals("고기")) 로 감쌀 수도 있음
            %>
            <li <%= ("menu".equals(category) ? "class='active'" : "") %>>
                <a href="search_Result.jsp?keyword=<%= java.net.URLEncoder.encode(keyword, "UTF-8") %>&category=menu">
                    메뉴 (<%= menuCount %>)
                </a>
            </li>
        </ul>
    </div>
    <hr class="divider" />

    <%
    // 맛집(음식점) 탭
    if("restaurant".equals(category)) {
%>
    <!-- 음식점 검색결과: 글자 크게 / 검색결과 개수 주황색 -->
    <h2 class="result-title">
        <span class="result-label">음식점</span> 검색결과 <span class="result-count"><%= rstCount %>건</span>
    </h2>
    <div class="result-list">
        <%
            for(RestaurantBean rb : rstList) {
                // 이미지가 null 또는 공백이면 대체 이미지 사용 ("이미지 준비중.png")
                
                String imgPath = rb.getImgpath();
			    
                
                String rstImg;

                if (imgPath != null && !imgPath.trim().isEmpty()) {
                    if (!imgPath.startsWith("http")) {
                        imgPath = request.getContextPath() + "/" + imgPath;
                    }
                    rstImg = imgPath;
                } else {
                    rstImg = request.getContextPath() + "/project/img/photoready.png";
                }

                // 한줄 설명이 null 또는 공백이면 "준비중 입니다" 표시
                String rstIntro = (rb.getRst_introduction() != null && !rb.getRst_introduction().trim().equals("")) 
                                  ? rb.getRst_introduction() 
                                  : "준비중 입니다";
        %>
        <div class="food-item">
            <!-- 사진 부분 클릭 시 상세보기 페이지로 이동 -->
            <div class="food-img">
                <a href="rst/rst_Detail.jsp?rst_id=<%= rb.getRst_id() %>">
                    <img src="<%= rstImg %>" alt="<%= rb.getRst_name() %>" />
                </a>
            </div>
            <!-- 제목 부분 클릭 시 상세보기 페이지로 이동 -->
            <div class="food-info">
                <h3>
                    <a href="rst/rst_Detail.jsp?rst_id=<%= rb.getRst_id() %>">
                        <%= rb.getRst_name() %>
                    </a>
                </h3>
                <p><%= rstIntro %></p>
            </div>
        </div>
        <%
            }
        %>
    </div>
<%
    // 메뉴 탭
    } else if("menu".equals(category)) {
%>
    <h2 class="result-title">
        <span class="result-label">메뉴</span> 검색결과 <span class="result-count"><%= menuCount %>건</span>
    </h2>
    <div class="result-list">
        <%
            for(MenuBean mb : menuList) {
                // 메뉴 이미지 처리: null 또는 공백이면 대체 이미지 사용
                String menuImg = (mb.getMenu_image() != null && !mb.getMenu_image().trim().equals(""))
                                  ? mb.getMenu_image() 
                                  : (request.getContextPath() + "/project/img/photoready.png");
                // 메뉴 설명: null 또는 공백이면 "준비중 입니다" 표시
                String menuDesc = (mb.getMenu_contents() != null && !mb.getMenu_contents().trim().equals(""))
                                  ? mb.getMenu_contents() 
                                  : "준비중 입니다";
        %>
        <div class="food-item">
            <div class="food-img">
                <a href="<%= request.getContextPath() %>/menu/MenuDetail.jsp?menuId=<%= mb.getMenu_id() %>">
                    <img src="<%= menuImg %>" alt="<%= mb.getMenu_name() %>" />
                </a>
            </div>
            <div class="food-info">
                <h3>
                    <a href="<%= request.getContextPath() %>/menu/MenuDetail.jsp?menuId=<%= mb.getMenu_id() %>">
                        <%= mb.getMenu_name() %>
                    </a>
                </h3>
                <p><%= menuDesc %></p>
            </div>
        </div>
        <%
            }
        %>
    </div>
<%
    }
%>
</div>
<!-- ▼ 페이징 컨트롤 ▼ -->
<div class="pagination">
  <!-- 첫 페이지 -->
  <% if (currentPage > 1) { %>
    <a href="?keyword=<%=java.net.URLEncoder.encode(keyword,"UTF-8")%>&category=<%=category%>&page=1">&laquo; 첫</a>
  <% } else { %>
    <span class="disabled">&laquo; 첫</span>
  <% } %>

  <!-- 이전 페이지 -->
  <% if (currentPage > 1) { %>
    <a href="?keyword=<%=java.net.URLEncoder.encode(keyword,"UTF-8")%>&category=<%=category%>&page=<%=currentPage-1%>">&lsaquo; 이전</a>
  <% } else { %>
    <span class="disabled">&lsaquo; 이전</span>
  <% } %>

  <!-- 페이지 번호 -->
  <% for (int i = blockStart; i <= blockEnd; i++) {
       if (i == currentPage) { %>
    <span class="current"><%=i%></span>
  <% } else { %>
    <a href="?keyword=<%=java.net.URLEncoder.encode(keyword,"UTF-8")%>&category=<%=category%>&page=<%=i%>"><%=i%></a>
  <% } } %>

  <!-- 다음 페이지 -->
  <% if (currentPage < totalPages) { %>
    <a href="?keyword=<%=java.net.URLEncoder.encode(keyword,"UTF-8")%>&category=<%=category%>&page=<%=currentPage+1%>">다음 &rsaquo;</a>
  <% } else { %>
    <span class="disabled">다음 &rsaquo;</span>
  <% } %>

  <!-- 마지막 페이지 -->
  <% if (currentPage < totalPages) { %>
    <a href="?keyword=<%=java.net.URLEncoder.encode(keyword,"UTF-8")%>&category=<%=category%>&page=<%=totalPages%>">마지막 &raquo;</a>
  <% } else { %>
    <span class="disabled">마지막 &raquo;</span>
  <% } %>
</div>
<%-- ▲ 페이징 컨트롤 끝 ▲ --%>
<jsp:include page="footer.jsp"/>
</body>
</html>
