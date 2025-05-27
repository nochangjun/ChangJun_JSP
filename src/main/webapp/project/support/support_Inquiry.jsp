<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.util.*, project.*" %>
<jsp:useBean id="mgr" class="project.InquiryMgr"/>
<jsp:useBean id="bean" class="project.InquiryBean"/>
<%
	String memberId = (String)session.getAttribute("idKey");
	String loginType = (String) session.getAttribute("loginType");
	boolean isLoggedIn = (memberId != null);

	int totalRecord = 0;
	int numPerPage = 8;
	int pagePerBlock = 5;
	int totalPage = 0;
	int totalBlock = 0;
	int nowPage = 1;
	int nowBlock = 1;

	if(request.getParameter("nowPage") != null) {
		nowPage = Integer.parseInt(request.getParameter("nowPage"));
	}

	String keyword = request.getParameter("keyword");

	int start = (nowPage * numPerPage) - numPerPage;
	List<InquiryBean> inquiryList = mgr.getFilteredInquiryList2(null, null, keyword, start, numPerPage, "inq_id", "desc");
	totalRecord = mgr.getFilteredInquiryCount(null, null, keyword);

	totalPage = (int)Math.ceil((double)totalRecord / numPerPage);
	totalBlock = (int)Math.ceil((double)totalPage / pagePerBlock);
	nowBlock = (int)Math.ceil((double)nowPage / pagePerBlock);
	
	// 현재 URL 인코딩해서 login.jsp에 넘기기 위함
    String currentURL = request.getRequestURI();
    String query = request.getQueryString();
    if (query != null) {
        currentURL += "?" + query;
    }
    String encodedURL = java.net.URLEncoder.encode(currentURL, "UTF-8");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>문의글</title>
<link rel="stylesheet" type="text/css" href="../css/support_Inquiry.css">
<jsp:include page="../header.jsp" />
<script>
	function writeInquiry() {
		const isLoggedIn = <%= isLoggedIn %>;
		if (!isLoggedIn) {
			document.getElementById("yummy-loginAlertModal").style.display = "flex";
			return;
		}
		location.href = "support_Inquiry_Write.jsp";
	}

	function pageing(page) {
		document.readFrm.nowPage.value = page;
		document.readFrm.submit();
	}
	function block(block) {
		document.readFrm.nowPage.value = <%= pagePerBlock %> * (block - 1) + 1;
		document.readFrm.submit();
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
</head>
<body>
<div class="inq-center-container"> <!-- ✅ 가운데 정렬 컨테이너 -->

	<div class="inq-content">
		<h1>문의글</h1>

		<div class="inq-search-container">
			<form action="support_Inquiry.jsp" method="get">
				<input type="text" class="inq-search-box" name="keyword" value="<%= keyword != null ? keyword : "" %>" placeholder="검색어를 입력해주세요.">
				<button type="submit" class="inq-search-btn">검색</button>
			</form>
		</div>

		<table class="inq-table">
			<thead>
				<tr>
					<th width="8%">번호</th>
					<th width="15%">닉네임</th>
					<th width="57%">제목</th>
					<th width="20%">작성일</th>
				</tr>
			</thead>
			<tbody>
				<% if(inquiryList.size() == 0) { %>
				<tr>
					<td colspan="4">등록된 문의글이 없습니다.</td>
				</tr>
				<% } else {
					// 검색 결과일 때는 순서대로 1부터, 아닐 때는 전체 게시물 개수 기준으로
					for(int i = 0; i < inquiryList.size(); i++) {
						InquiryBean inquiry = inquiryList.get(i);
						int displayNum;
						
						if(keyword != null && !keyword.isEmpty()) {
							// 검색 결과일 때는 역순으로 (최신글이 위에 표시되므로)
							displayNum = inquiryList.size() - i;
						} else {
							// 일반 목록일 때는 전체 개수 기준
							displayNum = totalRecord - ((nowPage - 1) * numPerPage) - i;
						}
				%>
				<tr>
					<td><%= displayNum %></td>
					<td><%= inquiry.getMember_nickname() %></td>
					<td style="text-align: left; padding-left: 20px" onclick="viewDetail(<%= inquiry.getInq_id() %>)">
						<img src="../img/lock_icon.png" class="inq-lock-icon" alt="lock">
						<%= inquiry.getInq_title() %>
					</td>
					<td><%= inquiry.getInq_create_at().toString().substring(0, 10) %></td>
				</tr>
				<% } } %>
			</tbody>
		</table>

		<div class="inq-button-container">
			<button type="button" class="inq-write-btn" onclick="writeInquiry()">글 작성</button>
		</div>

		<div class="inq-pagination">
			<% if(totalPage > 0) {
				if(nowBlock > 1) { %>
					<a href="javascript:block(<%= nowBlock-1 %>)">&laquo;</a>
			<% }
				int pageStart = (nowBlock - 1) * pagePerBlock + 1;
				int pageEnd = Math.min(pageStart + pagePerBlock - 1, totalPage);
				for(int i = pageStart; i <= pageEnd; i++) {
			%>
				<a href="javascript:pageing(<%= i %>)" <%= (i == nowPage) ? "class='active'" : "" %>><%= i %></a>
			<% }
				if(nowBlock < totalBlock) { %>
					<a href="javascript:block(<%= nowBlock+1 %>)">&gt;</a>
					<a href="javascript:block(<%= totalBlock %>)">&raquo;</a>
			<% } } %>
		</div>
	</div>

	<form name="readFrm" method="get" action="support_Inquiry.jsp">
		<input type="hidden" name="nowPage" value="<%= nowPage %>">
		<% if(keyword != null && !keyword.isEmpty()) { %>
			<input type="hidden" name="keyword" value="<%= keyword %>">
		<% } %>
	</form>

</div> <!-- inq-center-container 끝 -->
<jsp:include page="../footer.jsp" />
<script>
	document.addEventListener("DOMContentLoaded", function () {
		const isLoggedIn = <%= isLoggedIn %>;
	
		window.viewDetail = function(inquiryId) {
			if (!isLoggedIn) {
				document.getElementById("yummy-loginAlertModal").style.display = "flex";
				return;
			}
			location.href = "support_Inquiry_Detail.jsp?id=" + inquiryId;
		}

	});
</script>
</body>
</html>