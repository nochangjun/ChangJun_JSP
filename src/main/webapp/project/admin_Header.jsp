<!-- admin_Header.jsp -->
<%@ page contentType="text/html; charset=UTF-8" %>
<%
    String adminId = (String) session.getAttribute("admin_id");
    if (adminId == null) {
        response.sendRedirect("../login/login.jsp");
        return;
    }
    
    // 현재 페이지 경로 가져오기
    String currentURI = request.getRequestURI();
    
    // 페이지 그룹 매핑 정의 - 같은 메뉴에 속하는 페이지들을 그룹화
    boolean isMainPage = currentURI.contains("/main.jsp");
    boolean isDashboard = currentURI.contains("/admin_Main.jsp");
    boolean isUserManagement = currentURI.contains("/admin_UM.jsp");
    // 가게 관리 메뉴에 속하는 여러 페이지들
    boolean isRestaurantManagement = currentURI.contains("/admin_Rst_Approval.jsp") || 
                                 currentURI.contains("/admin_Rst_List.jsp");
    boolean isCourseRegister = currentURI.contains("/admin_Course_Register.jsp");
    // 이벤트 관리 메뉴에 속하는 여러 페이지들
    boolean isEventManagement = currentURI.contains("/admin_Event_Register.jsp") || 
                            currentURI.contains("/admin_Event_Participants.jsp") || 
                            currentURI.contains("/admin_Event_Delete.jsp");
    boolean isInquiryManagement = currentURI.contains("/admin_Inquiry.jsp");
    boolean isReportManagement = currentURI.contains("/admin_Report.jsp");
%>
<!-- 필수 폰트만 로드 -->
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap">
<!-- 헤더 CSS 로드 - 캐시 방지를 위한 버전 파라미터 추가 -->
<link rel="stylesheet" href="${pageContext.request.contextPath}/project/css/admin_Header.css?v=1.4">

<!-- 사이드바 영역 -->
<div id="adminSidebar" class="admin-sidebar">
    <h2>JEJUWEB</h2>
    <ul>
        <li><a href="../main.jsp" class="<%= isMainPage ? "admin-active" : "" %>">사이트 바로가기</a></li>
        <li class="admin-disabled">사이트 관리</li>
        <li><a href="${pageContext.request.contextPath}/project/admin/admin_Main.jsp" class="<%= isDashboard ? "admin-active" : "" %>">대시보드</a></li>
        <li><a href="${pageContext.request.contextPath}/project/admin/admin_UM.jsp" class="<%= isUserManagement ? "admin-active" : "" %>">사용자 관리</a></li>
        <li><a href="${pageContext.request.contextPath}/project/admin/admin_Rst_Approval.jsp" class="<%= isRestaurantManagement ? "admin-active" : "" %>">가게 승인/관리</a></li>
        <li><a href="${pageContext.request.contextPath}/project/admin/admin_Course_Register.jsp" class="<%= isCourseRegister ? "admin-active" : "" %>">맛집 코스 등록</a></li>
        <li><a href="${pageContext.request.contextPath}/project/admin/admin_Event_Register.jsp" class="<%= isEventManagement ? "admin-active" : "" %>">이벤트 등록/관리</a></li>
        <li><a href="${pageContext.request.contextPath}/project/admin/admin_Inquiry.jsp" class="<%= isInquiryManagement ? "admin-active" : "" %>">문의 관리</a></li>
        <li><a href="${pageContext.request.contextPath}/project/admin/admin_Report.jsp" class="<%= isReportManagement ? "admin-active" : "" %>">신고 관리</a></li>
    </ul>
</div>

<!-- 헤더 영역 -->
<div id="adminHeader" class="admin-header">
    <h2>YUMMY JEJU</h2>
    <button class="admin-logout" onclick="logout()">로그아웃</button>
</div>

<script>
    function logout() {
        window.location.href = '../login/logout_Proc.jsp';
    }
    
    // 자바스크립트 백업 메뉴 활성화 (JSP가 작동하지 않을 경우를 대비)
    document.addEventListener("DOMContentLoaded", function() {
        // JSP 코드가 이미 메뉴를 활성화했는지 확인
        const hasActiveMenu = document.querySelector(".admin-sidebar ul li a.admin-active");
        
        // JSP로 활성화된 메뉴가 없을 경우에만 자바스크립트로 처리
        if (!hasActiveMenu) {
            const currentPath = window.location.pathname;
            
            // 페이지 그룹 매핑 - 자바스크립트 버전
            const pageGroups = {
                'admin_Main.jsp': '대시보드',
                'admin_UM.jsp': '사용자 관리',
                'admin_Rst_Approval.jsp': '가게 승인/관리',
                'admin_Rst_List.jsp': '가게 승인/관리',
                'admin_Course_Register.jsp': '맛집 코스 등록',
                'admin_Event_Register.jsp': '이벤트 등록/관리',
                'admin_Event_Participants.jsp': '이벤트 등록/관리',
                'admin_Event_Delete.jsp': '이벤트 등록/관리',
                'admin_Inquiry.jsp': '문의 관리',
                'admin_Report.jsp': '신고 관리',
                'main.jsp': '사이트 바로가기'
            };
            
            // 현재 페이지 이름 추출
            const pageName = currentPath.split("/").pop().split("?")[0];
            
            // 현재 페이지가 속한 그룹 찾기
            const currentGroup = pageGroups[pageName];
            
            // 그룹에 맞는 메뉴 활성화
            if (currentGroup) {
                const sidebarLinks = document.querySelectorAll(".admin-sidebar ul li a");
                
                sidebarLinks.forEach(link => {
                    if (link.textContent.trim() === currentGroup) {
                        link.classList.add("admin-active");
                    }
                });
            }
        }
    });
</script>