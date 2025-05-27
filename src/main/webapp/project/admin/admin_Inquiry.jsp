<%@ page contentType="text/html; charset=UTF-8"%>
<%@ page import="java.util.*, project.InquiryBean, project.InquiryMgr" %>
<%
	request.setCharacterEncoding("UTF-8");

	String status = request.getParameter("status");
	String type = request.getParameter("type");
	String keyword = request.getParameter("keyword");

	// 정렬 파라미터
	String sort = request.getParameter("sort") != null ? request.getParameter("sort") : "inq_id";
	String order = request.getParameter("order") != null ? request.getParameter("order") : "desc";
	String toggleOrder = order.equals("asc") ? "desc" : "asc";

	int pageSize = 8;
	String pageNumParam = request.getParameter("pageNum");
	int currentPage = (pageNumParam != null) ? Integer.parseInt(pageNumParam) : 1;
	int startRow = (currentPage - 1) * pageSize;

	InquiryMgr mgr = new InquiryMgr();

	// 총 개수 및 리스트
	int totalCount = mgr.getFilteredInquiryCount(status, type, keyword);
	List<InquiryBean> inquiryList = mgr.getFilteredInquiryList(status, type, keyword, startRow, pageSize, sort, order);

	// 페이지네이션 계산
	int totalPage = (int) Math.ceil((double) totalCount / pageSize);
	int pageBlock = 5;
	int startPage = ((currentPage - 1) / pageBlock) * pageBlock + 1;
	int endPage = Math.min(startPage + pageBlock - 1, totalPage);
	int no = totalCount - startRow;
%>

<!DOCTYPE html>
<html lang="ko">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>문의 관리 - YUMMY JEJU</title>
	<link rel="stylesheet" href="../css/admin_Inquiry.css">
</head>
<body>
	<!-- 사이드바 및 헤더 인클루드 -->
	<%@ include file="../admin_Header.jsp" %>

	<!-- 메인 컨텐츠 영역 -->
	<div class="main-content">
		<!-- 문의 관리 섹션 - 향상된 UI -->
		<section class="inquiry-section">
			<h2>문의 관리</h2>
			
			<div class="filters">
				<form method="get" id="filterForm">
					<select name="status" onchange="this.form.submit()">
						<option value="">전체 상태</option>
						<option value="대기중" <%= "대기중".equals(status) ? "selected" : "" %>>대기중</option>
						<option value="완료" <%= "완료".equals(status) ? "selected" : "" %>>완료</option>
					</select>

					<select name="type" onchange="this.form.submit()">
						<option value="">전체 유형</option>
						<option value="계정문의" <%= "계정문의".equals(type) ? "selected" : "" %>>계정문의</option>
						<option value="가게문의" <%= "가게문의".equals(type) ? "selected" : "" %>>가게문의</option>
						<option value="기타" <%= "기타".equals(type) ? "selected" : "" %>>기타</option>
					</select>

					<input type="text" name="keyword" placeholder="제목 또는 작성자를 입력하세요" value="<%= keyword != null ? keyword : "" %>"/>
					<button type="submit" class="search-btn">검색</button>
				</form>
			</div>

			<div class="table-container">
				<table>
					<thead>
						<tr>
							<th>번호</th>
							<th>문의 유형</th>
							<th>제목</th>
							<th>작성자</th>
							<th>
								<a href="?sort=inq_create_at&order=<%= sort.equals("inq_create_at") ? toggleOrder : "asc" %>&status=<%= status != null ? status : "" %>&type=<%= type != null ? type : "" %>&keyword=<%= keyword != null ? keyword : "" %>">
									작성일 <%= sort.equals("inq_create_at") ? (order.equals("asc") ? "↑" : "↓") : "" %>
								</a>
							</th>
							<th>
								<a href="?sort=inq_status&order=<%= sort.equals("inq_status") ? toggleOrder : "asc" %>&status=<%= status != null ? status : "" %>&type=<%= type != null ? type : "" %>&keyword=<%= keyword != null ? keyword : "" %>">
									상태 <%= sort.equals("inq_status") ? (order.equals("asc") ? "↑" : "↓") : "" %>
								</a>
							</th>
							<th>관리</th>
						</tr>
					</thead>
					<tbody>
					<%
						if (inquiryList != null && !inquiryList.isEmpty()) {
							int displayNum = totalCount - ((currentPage - 1) * pageSize);
							for (InquiryBean ib : inquiryList) {
					%>
						<tr>
							<td><%= displayNum-- %></td>
							<td><%= ib.getInq_type() %></td>
							<td class="title-cell"><%= ib.getInq_title() %></td>
							<td><%= ib.getMember_name() %></td>
							<td><%= ib.getInq_create_at().toString().substring(0, 10) %></td>
							<td>
								<span class="status <%= ib.getInq_status().equals("대기중") ? "pending" : "completed" %>">
									<%= ib.getInq_status() %>
								</span>
							</td>
							<td>
								<button class="view-btn" data-inqid="<%= ib.getInq_id() %>">상세보기</button>
							</td>
						</tr>
					<%
							}
						} else {
					%>
						<tr>
							<td colspan="7">등록된 문의가 없습니다.</td>
						</tr>
					<% } %>
					</tbody>
				</table>
			</div>

			<!-- 페이지네이션 영역 -->
			<% if (totalPage > 0) { %>
			<div class="pagination">
				<% if (startPage > 1) { %>
					<a href="admin_Inquiry.jsp?pageNum=<%= startPage - 1 %>&status=<%= status != null ? status : "" %>&type=<%= type != null ? type : "" %>&keyword=<%= keyword != null ? keyword : "" %>&sort=<%= sort %>&order=<%= order %>" title="이전">&lsaquo;</a>
				<% } %>
				
				<% for (int i = startPage; i <= endPage; i++) {
					if (i == currentPage) { %>
						<strong><%= i %></strong>
				<%  } else { %>
						<a href="admin_Inquiry.jsp?pageNum=<%= i %>&status=<%= status != null ? status : "" %>&type=<%= type != null ? type : "" %>&keyword=<%= keyword != null ? keyword : "" %>&sort=<%= sort %>&order=<%= order %>"><%= i %></a>
				<%  }
				} %>
				
				<% if (endPage < totalPage) { %>
					<a href="admin_Inquiry.jsp?pageNum=<%= endPage + 1 %>&status=<%= status != null ? status : "" %>&type=<%= type != null ? type : "" %>&keyword=<%= keyword != null ? keyword : "" %>&sort=<%= sort %>&order=<%= order %>" title="다음">&rsaquo;</a>
				<% } %>			
			</div>
			<% } %>
		</section>
	</div>

	<script>
		// 상세보기 버튼 클릭 이벤트
		document.addEventListener('DOMContentLoaded', function() {
			document.querySelectorAll('.view-btn').forEach(btn => {
				btn.addEventListener('click', function () {
					const inqId = this.getAttribute('data-inqid');
					if (inqId) {
						window.open(
							'/myapp/admin/InquiryDetailServlet?inq_id=' + inqId,
							'inquiryDetail',
							'width=650,height=700,resizable=no,scrollbars=yes'
						);
					}
				});
			});
		});
	</script>
</body>
</html>