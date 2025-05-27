<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, project.EvtParticipantsMgr, project.EvtParticipantsBean" %>
<%
    request.setCharacterEncoding("UTF-8");

    String category = request.getParameter("searchCategory");
    String keyword = request.getParameter("searchKeyword");
    if (category == null) category = "전체";
    if (keyword == null) keyword = "";

    int pageSize = 10;
    int pageNum = 1;
    if (request.getParameter("page") != null)
        pageNum = Integer.parseInt(request.getParameter("page"));
    int startIndex = (pageNum - 1) * pageSize;

    EvtParticipantsMgr mgr = new EvtParticipantsMgr();
    Vector<EvtParticipantsBean> allList = mgr.getAllParticipants();
    Vector<EvtParticipantsBean> filtered = new Vector<>();
 
    // 🔍 검색 필터링
    for (EvtParticipantsBean bean : allList) {
        String title = bean.getEvt_title().toLowerCase();
        String content = bean.getEvt_content().toLowerCase();
        String lowerKeyword = keyword.toLowerCase();

        if (category.equals("전체") && (title.contains(lowerKeyword) || content.contains(lowerKeyword))) {
            filtered.add(bean);
        } else if (category.equals("제목") && title.contains(lowerKeyword)) {
            filtered.add(bean);
        } else if (category.equals("내용") && content.contains(lowerKeyword)) {
            filtered.add(bean);
        } else if (keyword.trim().isEmpty()) {
            filtered.add(bean); // 키워드가 없으면 전체 출력
        }
    }

    int total = filtered.size();
    int pageCount = (int) Math.ceil(total / (double) pageSize);
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>당첨자 발표 | YUMMY JEJU</title>
    <link rel="stylesheet" href="../css/header.css">
    <link rel="stylesheet" href="../css/footer.css">
    <link rel="stylesheet" href="../css/event_Result.css">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">
</head>
<body>
<jsp:include page="../header.jsp" />

<div class="event-container">
    <h1 class="event-title">이벤트</h1>

    <div class="event-tabs">
        <a href="event.jsp" class="tab">이벤트 참여</a>
        <a href="event_Result.jsp" class="tab active">당첨자 발표</a>
    </div>

    <% if (filtered.size() == 0) { %>
    <div class="no-results">
        <p>❌ 검색 결과가 없습니다.</p>
    </div>
    <% } else { %>
    <!-- 당첨자 발표 테이블 -->
    <div class="event-result-table">
        <table>
            <thead>
            <tr>
                <th class="column-title" style="text-align: center !important;">이벤트명</th>
                <th class="column-date">발표일</th>
            </tr>
            </thead>
            <tbody>
            <%
                for (int i = startIndex; i < Math.min(startIndex + pageSize, filtered.size()); i++) {
                    EvtParticipantsBean bean = filtered.get(i);
            %>
                <tr>
                    <td class="column-title">
                        <a href="event_Result_Detail.jsp?id=<%= bean.getEvt_id() %>"><%= bean.getEvt_title() %></a>
                    </td>
                    <td class="column-date"><%= bean.getEvt_created_at().substring(0, 10) %></td>
                </tr>
            <% } %>
            </tbody>
        </table>
    </div>
    <% } %>

	<!-- 검색창 -->
    <form method="get" action="event_Result.jsp" class="search-box">
        <select name="searchCategory" class="search-category">
            <option value="전체" <%=category.equals("전체") ? "selected" : ""%>>전체</option>
            <option value="제목" <%=category.equals("제목") ? "selected" : ""%>>제목</option>
            <option value="내용" <%=category.equals("내용") ? "selected" : ""%>>내용</option>
        </select>
        <input type="text" name="searchKeyword" class="search-input" value="<%=keyword%>" placeholder="검색어를 입력하세요">
        <button type="submit" class="search-buttons">검색</button>
    </form>

    <!-- 페이지네이션 -->
    <div class="pagination">
        <ul>
            <% for (int i = 1; i <= pageCount; i++) { %>
                <li class="<%= (i == pageNum) ? "active" : "" %>">
                    <a href="event_Result.jsp?page=<%=i%>&searchCategory=<%=category%>&searchKeyword=<%=keyword%>"><%=i%></a>
                </li>
            <% } %>
        </ul>
    </div>
</div>

<jsp:include page="../footer.jsp" />
</body>
</html>