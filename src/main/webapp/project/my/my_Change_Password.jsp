<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="project.MemberMgr, project.MemberBean"%>
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
<title>내 정보 관리</title>
<jsp:include page="../header.jsp" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/project/css/my_Common.css">
<script>
        // 페이지 로드시 실행
        window.onload = function() {
            setupSidebarNavigation();
        };
        
        // 네비게이션 설정
        function setupSidebarNavigation() {
            var menuItems = document.querySelectorAll('.sidebar li');
            
            menuItems.forEach(function(item, index) {
                item.addEventListener('click', function() {
                    if (index === 0) {
                        window.location.href = 'my_Update_Profile.jsp';
                    } else if (index === 2) {
                        window.location.href = 'my_Delete_Account.jsp';
                    } else if (index === 3) {
    					window.location.href = 'my_Store_Update.jsp';
    				}
                });
            });
        }
        
        function checkNewPassword() {
        	const currentPw = document.getElementsByName("currentPassword")[0].value;
            const newPw = document.getElementById("newPassword").value;
            const msg = document.getElementById("newPwMessage");

            msg.className = "info-msg"; // 초기화

            if (newPw.length < 8 || newPw.length > 16) {
                msg.textContent = "비밀번호는 8~16자까지 입력 가능합니다.";
                msg.classList.add("error");
            } else if (newPw === currentPw && newPw !== "") {
            	msg.textContent = "현재 비밀번호와 동일한 비밀번호입니다.";
                msg.classList.add("error");
            } else {
                msg.textContent = "사용 가능한 비밀번호 입니다.";
                msg.classList.add("success");
            }

            checkConfirmPassword(); // 재확인도 같이 검사
        }

        function checkConfirmPassword() {
        	const newPw = document.getElementById("newPassword").value;
            const confirmPw = document.getElementById("confirmPassword").value;
            const msg = document.getElementById("confirmPwMessage");

            msg.className = "info-msg";

            if (confirmPw === newPw && confirmPw !== "") {
                msg.textContent = "입력한 비밀번호가 일치합니다.";
                msg.classList.add("success");
            } else {
                msg.textContent = "";
            }
        }
        
        function togglePassword(inputId, iconElement) {
            const input = document.getElementById(inputId);

            if (input.type === "password") {
                input.type = "text";
                iconElement.textContent = "👁️";  // 눈 가린 아이콘
            } else {
                input.type = "password";
                iconElement.textContent = "🙈"; // 눈 아이콘
            }
        }
        
        // 폼 제출 처리
        function submitForm() {
		    const currentPw = document.getElementsByName('currentPassword')[0].value;
		    const newPw = document.getElementById('newPassword').value;
		    const confirmPw = document.getElementById('confirmPassword').value;
		
		    if (currentPw.trim() === '' || newPw.trim() === '' || confirmPw.trim() === '') {
		        alert('모든 항목을 입력해주세요.');
		        return false;
		    }
		
		    // 최종 검사: 길이 + 중복 여부 + 일치 여부는 이미 실시간으로 확인했지만 한 번 더 안전하게 확인 가능
		    if (newPw.length < 8 || newPw.length > 16) {
		        alert('비밀번호는 8~16자여야 합니다.');
		        return false;
		    }
		    if (currentPw === newPw) {
		        alert('기존 비밀번호와 동일합니다. 다시 입력해주세요.');
		        return false;
		    }
		    if (newPw !== confirmPw) {
		        alert('새 비밀번호와 확인이 일치하지 않습니다.');
		        return false;
		    }
		
		    // 유효하면 제출
		    document.getElementById('passwordForm').submit();
		}
        
        function cancelForm() {
            // 폼 입력값 초기화
            document.getElementById('passwordForm').reset();

            // 메시지도 함께 초기화
            document.getElementById('newPwMessage').textContent = '';
            document.getElementById('confirmPwMessage').textContent = '';
        }
    </script>
</head>
<body>

<!-- 스코프 클래스 추가 -->
<div class="my-common-scope">
	<div class="container">
		<h1>내 정보 관리</h1>

		<div class="content-wrapper">
			<div class="sidebar">
				<ul>
					<li>개인정보변경</li>
					<li class="active">비밀번호 변경</li>
					<li>회원탈퇴</li>
					<%if ("가게사장".equals(member.getMember_role())) { %>
						<li>가게정보수정</li>
					<%} %>
				</ul>
			</div>

			<div class="main-content">
				<div class="section-title">
					<h2>▶ 비밀번호 변경</h2>
					<span class="section-description">비밀번호는 주기적으로 변경하시기 바랍니다.</span>
				</div>

				<form id="passwordForm" action="my_Change_Password_Proc.jsp" method="post">
					<div class="form-group horizontal">
						<label class="form-label pw-form-label" style="min-width: 140px;">현재 비밀번호 입력</label>
					    <div class="input-container">
					        <div class="input-wrapper">
					            <input type="password" class="form-control password-input" name="currentPassword">
					        </div>
					    </div>
					</div>

					<div class="form-group horizontal">
						<label class="form-label pw-form-label" style="min-width: 140px;">새 비밀번호 입력</label>
						<div class="input-container">
							<div class="input-wrapper">
								<input type="password" class="form-control password-input"
									   name="newPassword" id="newPassword" oninput="checkNewPassword()">
								<span class="eye-toggle" onclick="togglePassword('newPassword', this)">🙈</span>
							</div>
							<small id="newPwMessage" class="info-msg" style="margin-left: 10px;"></small>
						</div>
					</div>

					<div class="form-group horizontal">
					    <label class="form-label pw-form-label" style="min-width: 140px;">새 비밀번호 재확인</label>
					    <div class="input-container">
					        <div class="input-wrapper">
					            <input type="password" class="form-control password-input"
					                   name="confirmPassword" id="confirmPassword"
					                   oninput="checkConfirmPassword()">
					            <span class="eye-toggle" onclick="togglePassword('confirmPassword', this)">🙈</span>
					        </div>
					        <small id="confirmPwMessage" class="info-msg" style="margin-left: 10px;"></small>
					    </div>
					</div>

					<div class="btn-area">
						<button type="button" class="btn" onclick="submitForm()">확인</button>
						<button type="button" class="btn btn-cancel"
							onclick="cancelForm()">다시입력</button>
					</div>
				</form>
			</div>
		</div>
	</div>
</div>

	<!-- Footer 포함 -->
	<jsp:include page="../footer.jsp" />
</body>
</html>