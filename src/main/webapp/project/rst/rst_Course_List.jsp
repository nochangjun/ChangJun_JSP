<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="project.AdminCourseMgr, project.AdminCourseBean" %>
<%@ page import="project.RestaurantCourseBookmarkMgr" %>
<%@ page import="java.util.Vector" %>
<%
	String order = request.getParameter("order");
	if (order == null || order.trim().equals("")) order = "new"; // 기본값은 최신순

    int pageSize = 5; // 한 페이지에 5개
    String pageNum = request.getParameter("page");
    if (pageNum == null || pageNum.trim().equals("")) pageNum = "1";

    int currentPage = Integer.parseInt(pageNum);
    int startRow = (currentPage - 1) * pageSize;

    AdminCourseMgr mgr = new AdminCourseMgr();
    Vector<AdminCourseBean> courseList = mgr.getCourseList(startRow, pageSize, order);
    int totalCount = mgr.getCourseCount();
    int pageCount = (int)Math.ceil((double)totalCount / pageSize);

    String loginId = (String) session.getAttribute("idKey");
    RestaurantCourseBookmarkMgr bookmarkMgr = new RestaurantCourseBookmarkMgr();
%>

<!DOCTYPE html>
<html lang="ko">
	<head>
	  <meta charset="UTF-8" />
	  <meta name="viewport" content="width=device-width, initial-scale=1.0">
	  <title>하루 맛집 코스</title>
	  <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;700&display=swap">
	  <link rel="stylesheet" type="text/css" href="../css/rst_Course_List.css">
	  <jsp:include page="../header.jsp" />
	</head>
	<body>
	<!-- 로그인 알림 모달 -->
	<div id="yummy-loginAlertModal" class="modal" style="display:none;">
	  <div class="modal-content">
	    <p>로그인이 필요한 서비스입니다.</p>
	    <button onclick="goToLogin()">로그인하기</button>
	    <button onclick="closeLoginModal()">닫기</button>
	  </div>
	</div>
	
	<div class="container">
	  <h1 class="header-title">하루 맛집 코스</h1>
	  
	  <div class="top-bar">
	    <div class="info">
	      총 <span class="highlight"><%= totalCount %></span>개의 코스를 확인해보세요
	    </div>
		<div class="sort-options">
		  <a href="rst_Course_List.jsp?order=new&page=1" <%= "new".equals(order) ? "class='active'" : "" %>>최신순</a> 
		  <a href="rst_Course_List.jsp?order=popular&page=1" <%= "popular".equals(order) ? "class='active'" : "" %>>인기순</a>
	    </div>
	  </div>
	
	  <ul class="course-list">
	  <% if (courseList.isEmpty()) { %>
	    <li style="text-align: center; padding: 40px 0;">등록된 코스가 없습니다.</li>
	  <% } else {
	      for (AdminCourseBean bean : courseList) {
	          boolean isBookmarked = false;
	          if (loginId != null) {
	              isBookmarked = bookmarkMgr.checkCourseBookmark(loginId, bean.getCourseId());
	          }
	  %>
	    <li class="course-item">
	      <img src="<%= (bean.getImagePath() != null && !bean.getImagePath().isEmpty()) 
	              ? request.getContextPath() + "/" + bean.getImagePath() 
	              : "https://cdn.pixabay.com/photo/2017/07/31/20/58/soup-2552622_1280.jpg" %>" 
	          alt="코스 이미지" onclick="location.href='rst_Day_Course.jsp?id=<%= bean.getCourseId() %>'" />
	
	      <div class="course-info" onclick="location.href='rst_Day_Course.jsp?id=<%= bean.getCourseId() %>'">
	          <div class="course-title"><%= bean.getCourseTitle() %></div>
	          <div class="course-subtitle"><%= bean.getDescription() %></div>
	      </div>
	      
	      <div class="course-actions">
			<button class="menu-toggle" aria-label="메뉴 열기">⋮</button>
			<div class="dropdown-menu">
			  <button type="button" onclick="toggleBookmark(<%= bean.getCourseId() %>, this)">
			    <%= isBookmarked ? "북마크 해제" : "북마크" %>
			  </button>
			  <button type="button" onclick="copyCourseUrl(<%= bean.getCourseId() %>)">URL복사</button>
			</div>
		  </div>
	    </li>
	  <% }
	   } %>
	  </ul>
	
	  <div class="pagination">
	    <%
	       // 페이지 번호 표시 로직 개선 - 현재 페이지 주변의 번호만 표시
	       int startPage = Math.max(1, currentPage - 2);
	       int endPage = Math.min(pageCount, currentPage + 2);
	       
	       for (int i = startPage; i <= endPage; i++) { %>
	      <a href="rst_Course_List.jsp?page=<%= i %>&order=<%= order %>" class="<%= i == currentPage ? "active" : "" %>"><%= i %></a>
	    <% }
	     %>
	  </div>
	</div>

<script>
  // 드롭다운 메뉴 토글
  document.querySelectorAll('.menu-toggle').forEach(function(button) {
    button.addEventListener('click', function(event) {
      var dropdown = this.nextElementSibling;
      
      // 다른 열린 드롭다운 메뉴 닫기
      document.querySelectorAll('.dropdown-menu.show').forEach(function(menu) {
        if (menu !== dropdown) {
          menu.classList.remove('show');
        }
      });
      
      dropdown.classList.toggle('show');
      event.stopPropagation();
    });
  });
  
  // 다른 곳 클릭 시 드롭다운 메뉴 닫기
  document.addEventListener('click', function() {
    document.querySelectorAll('.dropdown-menu.show').forEach(function(menu) {
      menu.classList.remove('show');
    });
  });

  // URL 복사 기능
function copyCourseUrl(courseId) {
  const url = window.location.origin + '<%= request.getContextPath() %>/project/rst/rst_Day_Course.jsp?id=' + courseId;

  if (navigator.clipboard) {
    navigator.clipboard.writeText(url)
      .then(() => alert("코스 상세 URL이 복사되었습니다!"))
      .catch(err => {
        console.error("클립보드 복사 실패:", err);
        alert("복사에 실패했습니다.");
      });
  } else {
    // fallback
    const textarea = document.createElement("textarea");
    textarea.value = url;
    document.body.appendChild(textarea);
    textarea.select();
    try {
      document.execCommand("copy");
      alert("코스 상세 URL이 복사되었습니다!");
    } catch (err) {
      alert("복사에 실패했습니다.");
    }
    document.body.removeChild(textarea);
  }
}


  // 북마크 토글 기능
  function toggleBookmark(courseId, button) {
    const userId = "<%= (String) session.getAttribute("idKey") %>";
    if (!userId || userId === "null") {
      document.getElementById("yummy-loginAlertModal").style.display = "flex";
      return;
    }

    fetch('<%= request.getContextPath() %>/project/RstCourseBookmarkServlet', {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded"
      },
      body: "course_id=" + courseId
    })
    .then(res => res.json())
    .then(data => {
      if (data.success) {
        const isBookmarked = data.coursebookmarked;
        button.textContent = isBookmarked ? "북마크 해제" : "북마크";
        alert(isBookmarked ? "북마크 되었습니다!" : "북마크가 해제되었습니다.");
      } else {
        alert("처리 중 오류가 발생했습니다.");
      }
    })
    .catch(err => {
      console.error("북마크 요청 실패:", err);
      alert("서버 오류가 발생했습니다.");
    });
  }

  // 로그인 페이지로 이동
  function goToLogin() {
    const currentUrl = window.location.pathname + window.location.search;
    const encodedUrl = encodeURIComponent(currentUrl);
    window.location.href = "<%=request.getContextPath()%>/project/login/login.jsp?url=" + encodedUrl;
  }

  // 로그인 모달 닫기
  function closeLoginModal() {
    document.getElementById("yummy-loginAlertModal").style.display = "none";
  }
</script>
<jsp:include page="../footer.jsp"/>
</body>
</html>