<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="project.MemberMgr, project.AdminBean" %>
<% 
    request.setCharacterEncoding("UTF-8");
    
    // 관리자 비밀번호 찾기를 위해 이메일과 아이디를 입력받음
    String adminId = request.getParameter("adminid");
    String email = request.getParameter("email");
    
    MemberMgr mgr = new MemberMgr();
    // 이메일로 관리자 정보를 조회
    AdminBean bean = mgr.getAdminByEmail(email);
    
    boolean isFound = (bean != null && bean.getAdmin_id().equals(adminId));
    String adminPwd = isFound ? bean.getAdmin_pwd() : "";
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>YUMMY JEJU - 관리자 비밀번호 찾기</title>
    <link rel="stylesheet" href="../css/login.css">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script>
        // 팝업 닫기
        function closePopup() {
            document.querySelector('.popup-overlay').style.display = 'none';
        }
        
        // 로그인 페이지로 이동
        function goToLogin() {
            location.href = 'login.jsp?loginType=partner';
        }
        
        // 뒤로가기
        function goBack() {
            history.back();
        }
    </script>
</head>
<body>
    <div class="login-container">
        <h1 class="login-title">YUMMY JEJU</h1>
        <h2 class="login-header">관리자 비밀번호 찾기</h2>
        <form action="admin_Find_Pwd_Proc.jsp" method="post">
            <label for="adminid" class="custom-label">아이디</label>
            <input type="text" id="adminid" name="adminid" class="input-field" placeholder="아이디를 입력하세요" required>
            
            <label for="email" class="custom-label">이메일</label>
            <input type="email" id="email" name="email" class="input-field" placeholder="이메일을 입력하세요" required>
            
            <button type="submit" class="login-button" style="margin-top:20px;">비밀번호 찾기</button>
        </form>
        <div class="extra-links">
            <a href="login.jsp?loginType=partner">관리자 로그인으로 이동</a>
        </div>
    </div>
    
    <!-- 팝업 창 -->
    <div class="popup-overlay" style="display: block;">
        <div class="popup-container <%= isFound ? "success-popup" : "error-popup" %>">
            <div class="popup-content">
                <h3 class="popup-title"><%= isFound ? "비밀번호 찾기 성공" : "비밀번호 찾기 실패" %></h3>
                <% if(isFound) { %>
                    <p class="popup-message">관리자 비밀번호를 찾았습니다.</p>
                    <div class="popup-id-box"><%= adminPwd %></div>
                    <div class="popup-buttons">
                        <button class="popup-button" onclick="goToLogin()">로그인하기</button>
                    </div>
                <% } else { %>
                    <p class="popup-message">입력하신 정보와 일치하는 관리자 정보가 없습니다.</p>
                    <div class="popup-buttons">
                        <button class="popup-button" onclick="goBack()">다시 시도하기</button>
                    </div>
                <% } %>
            </div>
        </div>
    </div>
</body>
</html>