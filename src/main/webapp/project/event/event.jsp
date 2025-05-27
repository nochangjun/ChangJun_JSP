<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.Vector" %>
<%@ page import="project.EventMgr, project.EventBean" %>
<%@ page import="java.time.LocalDate" %>
<%
    request.setCharacterEncoding("UTF-8");

    String status = request.getParameter("status");
    if (status == null) status = "진행중";

    String category = request.getParameter("searchCategory");
    String keyword = request.getParameter("searchKeyword");

    if (category == null) category = "전체";
    if (keyword == null) keyword = "";

    int pageSize = 6;
    int pageNum = 1;
    if (request.getParameter("page") != null)
        pageNum = Integer.parseInt(request.getParameter("page"));
    int startIndex = (pageNum - 1) * pageSize;

    EventMgr mgr = new EventMgr();
    mgr.updateEventStatuses(); 
    Vector<EventBean> allEvents = mgr.getVisibleEvents();

    LocalDate today = LocalDate.now();
    Vector<EventBean> filtered = new Vector<>();

    for (EventBean bean : allEvents) {
        LocalDate start = LocalDate.parse(bean.getStartDate());
        LocalDate end = LocalDate.parse(bean.getEndDate());

        String dynamicStatus = "";
        if (today.isBefore(start)) dynamicStatus = "예정";
        else if (!today.isAfter(end)) dynamicStatus = "진행중";
        else dynamicStatus = "종료";

        if (!dynamicStatus.equals(status)) continue;

        if (!keyword.trim().isEmpty()) {
            String lowerKeyword = keyword.toLowerCase();
            if (category.equals("제목") && !bean.getTitle().toLowerCase().contains(lowerKeyword)) continue;
            if (category.equals("내용") && !bean.getContent().toLowerCase().contains(lowerKeyword)) continue;
            if (category.equals("전체") &&
                !(bean.getTitle().toLowerCase().contains(lowerKeyword) ||
                  bean.getContent().toLowerCase().contains(lowerKeyword))) continue;
        }

        filtered.add(bean);
    }

    int totalCount = filtered.size();
    int pageCount = (int) Math.ceil(totalCount / (double) pageSize);
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>이벤트 참여 | YUMMY JEJU</title>
    <link rel="stylesheet" href="../css/header.css">
    <link rel="stylesheet" href="../css/footer.css">
    <link rel="stylesheet" href="../css/event.css">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">
</head>
<body>
    <jsp:include page="../header.jsp" />

    <div class="event-container">
        <h1 class="event-title">이벤트</h1>

        <div class="event-tabs">
            <a href="event.jsp" class="tab active">이벤트 참여</a>
            <a href="event_Result.jsp" class="tab">당첨자 발표</a>
        </div>

        <div class="event-status-filter">
            <a href="event.jsp?status=예정" class="<%=status.equals("예정") ? "active" : ""%>">예정</a>
            <a href="event.jsp?status=진행중" class="<%=status.equals("진행중") ? "active" : ""%>">진행중</a>
            <a href="event.jsp?status=종료" class="<%=status.equals("종료") ? "active" : ""%>">종료</a>
        </div>

        <div class="event-list">
        <%
            // 항상 두 개씩 표시하기 위한 로직
            for (int i = startIndex; i < Math.min(startIndex + pageSize, filtered.size()); i += 2) {
        %>
            <div class="event-row">
                <% 
                    // 첫 번째 아이템
                    EventBean bean = filtered.get(i);
                    LocalDate start = LocalDate.parse(bean.getStartDate());
                    LocalDate end = LocalDate.parse(bean.getEndDate());

                    String dynamicStatus = "";
                    if (today.isBefore(start)) dynamicStatus = "예정";
                    else if (!today.isAfter(end)) dynamicStatus = "진행중";
                    else dynamicStatus = "종료";
                %>
                <a href="event_Detail.jsp?event_id=<%=bean.getEventId()%>" class="event-item-link">
                    <div class="event-item">
                        <div class="event-image">
                            <img src="<%=request.getContextPath()%>/<%=bean.getImageUrl()%>" alt="이벤트 이미지">
                            <span class="event-status <%=dynamicStatus.equals("예정") ? "upcoming" : dynamicStatus.equals("진행중") ? "ongoing" : "ended"%>"><%=dynamicStatus%></span>
                        </div>
                        <div class="event-info">
                            <h3 class="event-name"><%=bean.getTitle()%></h3>
                            <p class="event-desc"><%=bean.getContent()%></p>
                            <p class="event-date"><%=bean.getStartDate()%> ~ <%=bean.getEndDate()%></p>
                        </div>
                    </div>
                </a>

                <% 
                    // 두 번째 아이템 (있는 경우)
                    if (i + 1 < Math.min(startIndex + pageSize, filtered.size())) {
                        bean = filtered.get(i + 1);
                        start = LocalDate.parse(bean.getStartDate());
                        end = LocalDate.parse(bean.getEndDate());

                        if (today.isBefore(start)) dynamicStatus = "예정";
                        else if (!today.isAfter(end)) dynamicStatus = "진행중";
                        else dynamicStatus = "종료";
                %>
                <a href="event_Detail.jsp?event_id=<%=bean.getEventId()%>" class="event-item-link">
                    <div class="event-item">
                        <div class="event-image">
                            <img src="<%=request.getContextPath()%>/<%=bean.getImageUrl()%>" alt="이벤트 이미지">
                            <span class="event-status <%=dynamicStatus.equals("예정") ? "upcoming" : dynamicStatus.equals("진행중") ? "ongoing" : "ended"%>"><%=dynamicStatus%></span>
                        </div>
                        <div class="event-info">
                            <h3 class="event-name"><%=bean.getTitle()%></h3>
                            <p class="event-desc"><%=bean.getContent()%></p>
                            <p class="event-date"><%=bean.getStartDate()%> ~ <%=bean.getEndDate()%></p>
                        </div>
                    </div>
                </a>
                <% } else { %>
                <!-- 두 번째 아이템이 없을 경우 빈 공간 유지를 위한 더미 요소 -->
                <div class="event-item-link" style="visibility: hidden;"></div>
                <% } %>
            </div>
        <% } %>

        <% if (filtered.size() == 0) { %>
            <div class="no-results">
                <p>❌ 해당 검색 결과가 없습니다.</p>
            </div>
        <% } %>
        </div>

        <form method="get" action="event.jsp" class="search-box">
            <input type="hidden" name="status" value="<%=status%>">
            <select name="searchCategory" class="search-category">
                <option value="전체" <%=category.equals("전체") ? "selected" : ""%>>전체</option>
                <option value="제목" <%=category.equals("제목") ? "selected" : ""%>>제목</option>
                <option value="내용" <%=category.equals("내용") ? "selected" : ""%>>내용</option>
            </select>
            <input type="text" name="searchKeyword" class="search-input" value="<%=keyword%>" placeholder="검색어를 입력하세요">
            <button type="submit" class="search-buttons">검색</button>
        </form>

        <div class="pagination">
            <ul>
                <% for (int i = 1; i <= pageCount; i++) { %>
                    <li class="<%= (i == pageNum) ? "active" : "" %>">
                        <a href="event.jsp?status=<%=status%>&searchCategory=<%=category%>&searchKeyword=<%=keyword%>&page=<%=i%>"><%=i%></a>
                    </li>
                <% } %>
            </ul>
        </div>
    </div>

    <jsp:include page="../footer.jsp" />
</body>
</html>