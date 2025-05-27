<%@page import="java.util.Vector"%>
<%@page import="project.MemberMgr, project.MemberBean"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%
request.setCharacterEncoding("UTF-8");

// 삭제 처리
if ("true".equals(request.getParameter("delete"))) {
	String[] ids = request.getParameterValues("member_id");
	if (ids != null && ids.length > 0) {
		MemberMgr deleteMgr = new MemberMgr();
		deleteMgr.deleteMembers(ids);
	}
	response.sendRedirect("admin_UM.jsp?deleted=true");
	return;
}

// 필터 처리
String type = request.getParameter("searchType");
String startDate = request.getParameter("startDate");
String endDate = request.getParameter("endDate");

MemberMgr mgr = new MemberMgr();
Vector<MemberBean> fullList;

if ("review".equals(type) && startDate != null && endDate != null) {
	fullList = mgr.getMembersByReviewPeriod(startDate, endDate);
} else if ("signup".equals(type) && startDate != null && endDate != null) {
	fullList = mgr.getMembersBySignupPeriod(startDate, endDate);
} else {
	fullList = mgr.getAllMembers();
}

int pageSize = 8;
String pageNumParam = request.getParameter("page");
int pageNum = pageNumParam != null ? Integer.parseInt(pageNumParam) : 1;
int totalCount = fullList.size();
int totalPage = (int) Math.ceil((double) totalCount / pageSize);
int startRow = (pageNum - 1) * pageSize;
int endRow = Math.min(startRow + pageSize, totalCount);
int pageBlock = 5;
int startPage = ((pageNum - 1) / pageBlock) * pageBlock + 1;
int endPage = startPage + pageBlock - 1;
if (endPage > totalPage) endPage = totalPage;

// 현재 날짜 가져오기
java.text.SimpleDateFormat dateFormat = new java.text.SimpleDateFormat("yyyy-MM-dd");
String today = dateFormat.format(new java.util.Date());
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>사용자 관리 - YUMMY JEJU</title>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap">
<link rel="stylesheet" type="text/css" href="../css/admin_UM.css">
<script>
let currentSortedCol = null;
let currentSortAsc = true;
let currentIndex = 0;
const pageSize = 10;

function loadMore() {
	const rows = document.querySelectorAll(".member-row");
	let shown = 0;
	for (let i = currentIndex; i < rows.length && shown < pageSize; i++) {
		rows[i].style.display = "table-row";
		shown++;
		currentIndex++;
	}
	if (currentIndex >= rows.length) {
		document.getElementById("loadMoreBtn").style.display = "none";
	}
}

function sortTable(button, colIndex) {
	const table = document.querySelector('table');
	const tbody = table.tBodies[0];
	const rows = Array.from(tbody.rows);
	const ascending = (button !== currentSortedCol || !currentSortAsc);

	rows.sort((a, b) => {
		const aText = a.cells[colIndex].innerText.trim();
		const bText = b.cells[colIndex].innerText.trim();
		if (colIndex === 4) {
			return ascending ? new Date(aText) - new Date(bText) : new Date(bText) - new Date(aText);
		} else if (colIndex === 5) {
			return ascending ? parseInt(aText) - parseInt(bText) : parseInt(bText) - parseInt(aText);
		} else {
			return ascending ? aText.localeCompare(bText) : bText.localeCompare(aText);
		}
	});
	rows.forEach(row => tbody.appendChild(row));
	document.querySelectorAll('th button').forEach(btn => btn.innerText = '▲');
	button.innerText = ascending ? '▲' : '▼';
	currentSortedCol = button;
	currentSortAsc = ascending;
}

function toggleAll(source) {
	document.querySelectorAll('input[name="member_id"]').forEach(cb => cb.checked = source.checked);
}

window.onload = function () {
	loadMore(); // 첫 페이지 로딩 시 10명 표시
	const params = new URLSearchParams(window.location.search);
	if (params.get('deleted') === 'true') {
		alert("✅ 선택한 회원이 삭제되었습니다.");
		history.replaceState({}, document.title, location.pathname);
	}
}

function checkDelete(e) {
	const deleteBtnClicked = e.submitter && e.submitter.name === "delete";
	if (deleteBtnClicked) {
		return confirm("정말 삭제하시겠습니까?");
	}
	// 검색 버튼이면 그냥 통과
	return true;
}
</script>
</head>
<body>
	<!-- 사이드바 및 헤더 인클루드 -->
	<%@ include file="../admin_Header.jsp" %>

	<!-- 메인 컨텐츠 영역 -->
	<div class="main-content">
		<h1>사용자 관리</h1>

		<!-- 회원 목록 조회 섹션 - 향상된 UI -->
		<div class="user-section">
			<h2>회원 목록 조회</h2>

			<form method="POST" action="admin_UM.jsp" onsubmit="return checkDelete(event);">
				<div class="search-bar">
					<select name="searchType">
						<option value="signup" <%="signup".equals(type) ? "selected" : ""%>>가입일</option>
						<option value="review" <%="review".equals(type) ? "selected" : ""%>>리뷰 작성일자</option>
					</select> 
					
					<input type="date" name="startDate" value="<%=startDate != null ? startDate : ""%>" max="<%= today %>"> 
					<span>-</span>
					<input type="date" name="endDate" value="<%=endDate != null ? endDate : ""%>" max="<%= today %>">

					<button type="submit">검색</button>
					<button type="submit" name="delete" value="true">삭제</button>
					<button type="button" onclick="location.href='admin_UM.jsp'">전체 보기</button>
				</div>

				<div class="table-container">
					<table>
						<thead>
							<tr>
								<th><input type="checkbox" onclick="toggleAll(this)"></th>
								<th>이름</th>
								<th>아이디</th>
								<th>이메일</th>
								<th>가입일
									<button type="button" onclick="sortTable(this, 4)">▲</button>
								</th>
								<th>리뷰 수
									<button type="button" onclick="sortTable(this, 5)">▲</button>
								</th>
								<th>등급
									<button type="button" onclick="sortTable(this, 6)">▲</button>
								</th>
							</tr>
						</thead>
						<tbody>
						<% if (totalCount > 0) {
							for (int i = startRow; i < endRow; i++) {
								MemberBean member = fullList.get(i);
						%>
						<tr>
							<td><input type="checkbox" name="member_id" value="<%=member.getMember_id()%>"></td>
							<td><%=member.getMember_name()%></td>
							<td><%=member.getMember_id()%></td>
							<td><%=member.getMember_email()%></td>
							<td><%=member.getMember_create_at().substring(0, 10)%></td>
							<td><%=member.getReview_count()%></td>
							<td><%=member.getMember_role()%></td>
						</tr>
						<% }} else { %>
						<tr><td colspan="7">회원이 없습니다.</td></tr>
						<% } %>
						</tbody>
					</table>
				</div>

				<!-- 페이지네이션 영역 -->
				<% if (totalPage > 0) { %>
				<div class="pagination">
					<% if (startPage > 1) { %>
						<a href="?page=<%= startPage - 1 %>&searchType=<%= type != null ? type : "" %>&startDate=<%= startDate != null ? startDate : "" %>&endDate=<%= endDate != null ? endDate : "" %>" title="이전">&lsaquo;</a>
					<% } %>
					
					<% for (int i = startPage; i <= endPage; i++) { %>
						<% if (i == pageNum) { %>
							<strong><%= i %></strong>
						<% } else { %>
							<a href="?page=<%= i %>&searchType=<%= type != null ? type : "" %>&startDate=<%= startDate != null ? startDate : "" %>&endDate=<%= endDate != null ? endDate : "" %>"><%= i %></a>
						<% } %>
					<% } %>
					
					<% if (endPage < totalPage) { %>
						<a href="?page=<%= endPage + 1 %>&searchType=<%= type != null ? type : "" %>&startDate=<%= startDate != null ? startDate : "" %>&endDate=<%= endDate != null ? endDate : "" %>" title="다음">&rsaquo;</a>
					<% } %>
				</div>
				<% } %>
			</form>
		</div>
	</div>
</body>
</html>