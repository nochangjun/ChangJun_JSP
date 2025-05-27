<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.*, project.*" %>
<jsp:useBean id="mgr" class="project.BoardMgr"/>
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
    Vector<BoardBean> boardList = mgr.getBoardList(start, numPerPage, keyword);
    totalRecord = mgr.getBoardCount(keyword);

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
<title>게시판</title>
<link rel="stylesheet" type="text/css" href="../css/support_Board.css">
<jsp:include page="../header.jsp" />
<script>
	function viewDetail(boardId) {
	    location.href = "support_Board_Detail.jsp?id=" + boardId;
	}
	
	function writeBoard() {
		const isLoggedIn = <%= isLoggedIn %>;

		if (!isLoggedIn) {
			document.getElementById("yummy-loginAlertModal").style.display = "flex";
			return;
		}
		location.href = "support_Board_Write.jsp";
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
<div class="board-center-container">

<div class="board-content">
    <h1>게시판</h1>

    <div class="board-search-container">
        <form action="support_Board.jsp" method="get">
            <input type="text" class="board-search-box" name="keyword" 
                value="<%= keyword != null ? keyword : "" %>"
                placeholder="검색어를 입력해주세요.">
            <button type="submit" class="board-search-btn">검색</button>
        </form>
    </div>

    <table class="board-table">
        <thead>
            <tr>
                <th width="8%">번호</th>
                <th width="15%">닉네임</th>
                <th width="45%">제목</th>
                <th width="15%">작성일</th>
                <th width="8%">댓글수</th>
                <th width="9%">조회수</th>
            </tr>
        </thead>
        <tbody>
        <% if(boardList.size() == 0) { %>
            <tr><td colspan="6">등록된 게시글이 없습니다.</td></tr>
        <% } else {
            int listNum = totalRecord - ((nowPage - 1) * numPerPage);
            for(int i = 0; i < boardList.size(); i++) {
                BoardBean board = boardList.get(i);
        %>
            <tr>
                <td><%= listNum-- %></td>
                <td><%= board.getMember_nickname() %></td>
                <td style="text-align: left; padding-left: 20px" 
                    onclick="viewDetail(<%= board.getBoard_id() %>)"><%= board.getBoard_title() %></td>
                <td><%= board.getBoard_at().substring(0, 10) %></td>
                <td><%= board.getComment_count() %></td>
                <td><%= board.getBoard_views() %></td>
            </tr>
        <% } } %>
        </tbody>
    </table>

    <div class="board-button-container">
        <button type="button" class="board-write-btn" onclick="writeBoard()">글 작성</button>
    </div>

    <div class="board-pagination">
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

<form name="readFrm" method="get" action="support_Board.jsp">
    <input type="hidden" name="nowPage" value="<%= nowPage %>">
    <% if(keyword != null && !keyword.isEmpty()) { %>
        <input type="hidden" name="keyword" value="<%= keyword %>">
    <% } %>
</form>

</div> 

<jsp:include page="../footer.jsp" />
</body>
</html>