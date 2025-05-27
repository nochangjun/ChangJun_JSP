<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.Vector, project.ReportBean, project.ReportMgr" %>
<%
    request.setCharacterEncoding("UTF-8");

    // 필터 및 정렬 파라미터 읽기
    String status = request.getParameter("status");
    String type = request.getParameter("type");
    String keyword = request.getParameter("keyword");
    if (status == null || status.trim().isEmpty() || "전체 상태".equals(status))
        status = "";
    if (type == null || type.trim().isEmpty() || "전체 유형".equals(type))
        type = "";
    if (keyword == null)
        keyword = "";

    String sort = request.getParameter("sort") != null ? request.getParameter("sort") : "report_id";
    String order = request.getParameter("order") != null ? request.getParameter("order") : "desc";
    String toggleOrder = order.equals("asc") ? "desc" : "asc";

    int pageSize = 8;
    int pageNum = request.getParameter("page") != null ? Integer.parseInt(request.getParameter("page")) : 1;
    int startRow = (pageNum - 1) * pageSize;

    ReportMgr mgr = new ReportMgr();
    int totalCount = mgr.getReportCount(status, type, keyword);
    Vector<ReportBean> reportList = mgr.getReportList(status, type, keyword, startRow, pageSize);
    int totalPage = (int) Math.ceil((double) totalCount / pageSize);

    int pageBlock = 5;
    int startPage = ((pageNum - 1) / pageBlock) * pageBlock + 1;
    int endPage = startPage + pageBlock - 1;
    if (endPage > totalPage)
        endPage = totalPage;
    
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>신고 관리</title>
    <link rel="stylesheet" href="../css/admin_Report.css">
    <script>
        // 필터 검색 실행
        function searchReports() {
            const status = document.getElementById("statusSelect").value;
            const type = document.getElementById("typeSelect").value;
            const keyword = document.getElementById("keywordInput").value;
            location.href = "<%= request.getRequestURI() %>?status=" + encodeURIComponent(status)
                            + "&type=" + encodeURIComponent(type)
                            + "&keyword=" + encodeURIComponent(keyword);
        }
        
        // 신고 삭제 기능 (Ajax)
        function deleteReport(reportId, event) {
            event.stopPropagation();
            if (confirm("정말 삭제하시겠습니까?")) {
                fetch("<%= request.getContextPath() %>/project/admin/deleteReport?report_id=" + reportId)
                    .then(response => response.text())
                    .then(result => {
                        if(result.trim() === "success"){
                            event.target.closest("tr").remove();
                        } else {
                            alert("삭제 처리 중 오류가 발생했습니다.");
                        }
                    })
                    .catch(error => {
                        console.error("삭제 중 에러 발생:", error);
                        alert("삭제 처리 중 오류가 발생했습니다.");
                    });
            }
        }
    </script>
</head>
<body>
    <!-- 사이드바 및 헤더 인클루드 -->
    <%@ include file="../admin_Header.jsp" %>
    
    <div class="main-content">
        <section class="report-section">
            <h2>신고 관리</h2>

            <div class="filters">
                <form method="get" id="filterForm">
                    <select id="statusSelect" name="status" onchange="this.form.submit()">
                        <option value="전체 상태" <%="".equals(status) ? "selected" : ""%>>전체 상태</option>
                        <option value="대기" <%= "대기".equals(status) ? "selected" : "" %>>대기</option>
                        <option value="완료" <%= "완료".equals(status) ? "selected" : "" %>>완료</option>
                    </select>

                    <select id="typeSelect" name="type" onchange="this.form.submit()">
                        <option value="전체 유형" <%="".equals(type) ? "selected" : ""%>>전체 유형</option>
                        <option value="board" <%= "board".equals(type) ? "selected" : "" %>>게시글</option>
                        <option value="comment" <%= "comment".equals(type) ? "selected" : "" %>>댓글</option>
                        <option value="review" <%= "review".equals(type) ? "selected" : "" %>>리뷰</option>
                    </select>

                    <input type="text" id="keywordInput" name="keyword" placeholder="검색어(신고자)" value="<%= keyword %>">
                    <button type="submit" class="search-btn">검색</button>
                </form>
            </div>

            <table>
                <thead>
                    <tr>
                        <th>번호</th>
                        <th>신고 유형</th>
                        <th>신고 내용</th>
                        <th>신고자</th>
                        <th>신고 대상</th>
                        <th>신고일</th>
                        <th>상태</th>
                        <th>관리</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    if (reportList != null && !reportList.isEmpty()) {
                        for (int i = 0; i < reportList.size(); i++) {
                            ReportBean rb = reportList.get(i);
                            String displayType = "게시글";
                            if ("comment".equals(rb.getReport_type()))
                                displayType = "댓글";
                            else if ("review".equals(rb.getReport_type()))
                                displayType = "리뷰";
                    %>
                    <tr class="report-row">
                        <td><%= totalCount - (startRow + i) %></td>
                        <td><%= displayType %></td>
                        <td>
                            <!-- 신고 상세보기를 위한 버튼: data-reportid 속성 부여 -->
                            <a href="#" class="view-btn" data-reportid="<%= rb.getReport_id() %>" onclick="event.stopPropagation();">
                                신고 내용보기
                            </a>
                        </td>
                        <td><%= rb.getReporter_id() %></td>
                        <td><%= rb.getReported_member_id() %></td>
                        <td><%= rb.getReport_created_at() %></td>
                        <td><%= rb.getReport_status() %></td>
                        <td><img src="../img/xx.png" alt="삭제" class="delete-icon" onclick="deleteReport(<%= rb.getReport_id() %>, event)"></td>
                    </tr>
                    <%
                        }
                    } else {
                    %>
                    <tr>
                        <td colspan="8">신고된 내역이 없습니다.</td>
                    </tr>
                    <%
                    }
                    %>
                </tbody>
            </table>

            <!-- 페이지네이션 -->
            <div class="pagination">
                <%
                    for (int i = 1; i <= totalPage; i++) {
                        if (i == pageNum) {
                %>
                <strong><%= i %></strong>
                <%
                        } else {
                %>
                <a href="?status=<%= status != null ? status : "" %>&type=<%= type != null ? type : "" %>&keyword=<%= keyword != null ? keyword : "" %>&sort=<%= sort %>&order=<%= order %>&page=<%= i %>">
                    <%= i %>
                </a>
                <%
                        }
                    }
                %>
            </div>
        </section>
    </div>

    <script>
        // 신고 상세보기 팝업 열기
        document.addEventListener('DOMContentLoaded', function() {
            document.querySelectorAll('.view-btn').forEach(btn => {
                btn.addEventListener('click', function () {
                    const reportId = this.getAttribute('data-reportid');
                    if (reportId) {
                        window.open(
                            '/myapp/admin/ReportDetailServlet?report_id=' + reportId,
                            'reportDetail',
                            'width=650,height=700,resizable=no,scrollbars=yes'
                        );
                    }
                });
            });
        });
    </script>
</body>
</html>