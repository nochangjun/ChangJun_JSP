<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="project.MemberMgr, project.MemberBean" %>
<%
    String id = (String) session.getAttribute("idKey");
    if (id == null) {
        response.sendRedirect("../login/login.jsp");
        return;
    }

    MemberMgr mgr = new MemberMgr();
    MemberBean member = mgr.getMember(id);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>내 정보 관리 - 네이버 로그인 회원</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/project/css/my_Common.css">
<jsp:include page="../header.jsp" />
<script>
	//페이지 로드시 실행
	window.onload = function () {
	    setupSidebarNavigation();
	};
	
	function setupSidebarNavigation() {
        const menuItems = document.querySelectorAll('.sidebar li');
        const pages = [
            'my_Update_Profile_Naver.jsp', // 현재 페이지
            'my_Delete_Account.jsp',
            'my_Store_Update.jsp'
        ];

        menuItems.forEach((item, index) => {
            item.addEventListener('click', function () {
                // 현재 페이지 클릭 시 이동 방지
                if (!item.classList.contains("active")) {
                    location.href = pages[index];
                }
            });
        });
    }
	
    function checkDuplicate(type) {
        const input = document.getElementById("userNickname");
        const message = document.getElementById("nicknameMessage");
        const value = input.value.trim();
        const original = input.dataset.original;

        if (!value) {
            message.textContent = "닉네임을 입력해주세요.";
            message.className = "info-msg error";
            return;
        }
        
        if (value === original) {
            message.textContent = "현재 사용 중인 닉네임입니다.";
            message.className = "info-msg";
            return;
        }

        fetch("<%= request.getContextPath() %>/project/CheckDuplicateServlet?type=nickname&value=" + encodeURIComponent(value))
            .then(res => res.text())
            .then(data => {
                if (data.trim() === "duplicate") {
                    message.textContent = "사용 불가능한 닉네임입니다.";
                    message.className = "info-msg error";
                } else {
                    message.textContent = "사용 가능한 닉네임입니다.";
                    message.className = "info-msg success";
                }
            })
            .catch(() => {
                message.textContent = "오류가 발생했습니다.";
                message.className = "info-msg error";
            });
    }
</script>
</head>
<body>
<div class="my-common-scope">
    <div class="container">
        <h1>내 정보 관리</h1>

        <div class="content-wrapper">
            <div class="sidebar">
                <ul>
                    <li class="active">개인정보변경</li>
                    <li>회원탈퇴</li>
                    <% if ("가게사장".equals(member.getMember_role())) { %>
                        <li>가게정보수정</li>
                    <% } %>
                </ul>
            </div>

            <div class="main-content">
                <div class="section-title">
                    <h2>▶ 개인정보변경</h2>
                    <span class="section-description">네이버 로그인 회원은 닉네임만 변경 가능합니다.</span>
                </div>

                <form action="my_Update_Profile_Naver_Proc.jsp" method="post">
                    <div class="form-group">
                        <div class="form-label profile-form-label">아이디</div>
                        <input type="text" class="form-control-store" name="userId" value="<%=member.getMember_id()%>" readonly>
                    </div>

                    <div class="form-group">
                        <div class="form-label profile-form-label">이름</div>
                        <input type="text" class="form-control-store" value="<%=member.getMember_name()%>" readonly>
                    </div>

                    <div class="form-group" style="flex-direction: column; align-items: flex-start;">
                        <div style="display: flex; align-items: center; margin-bottom: 4px;">
                            <div class="form-label profile-form-label" style="width: 50px;">닉네임</div>
                            <div style="display: flex; align-items: center;">
                                <input type="text" id="userNickname" name="userNickname" class="form-control-store" style="width: 312px;" value="<%=member.getMember_nickname()%>" data-original="<%=member.getMember_nickname()%>">
                                <button type="button" class="check-btn" onclick="checkDuplicate('nickname')">중복확인</button>
                            </div>
                        </div>
                        <div style="margin-left: 60px;">
                            <small id="nicknameMessage" class="info-msg"></small>
                        </div>
                    </div>

                    <div class="withdraw-button-wrapper">
                        <button type="submit" class="btn">저장</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../footer.jsp" />
</body>
</html>