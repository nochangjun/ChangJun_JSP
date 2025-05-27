<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>YUMMY JEJU - 회원가입</title>
  <link rel="stylesheet" href="../css/login.css">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  
    <script>
      function checkDuplicate(field) {
        if (field === "아이디") {
          var userid = document.querySelector('input[name="userid"]').value;
          if (!userid) {
            alert("아이디를 먼저 입력하세요.");
            return;
          }
          var xhr = new XMLHttpRequest();
          xhr.open("GET", "CheckIdServlet?userid=" + encodeURIComponent(userid), true);
          xhr.onreadystatechange = function() {
            if (xhr.readyState === 4 && xhr.status === 200) {
              var isDuplicate = xhr.responseText.trim();
              if (isDuplicate === "true") {
                alert("이미 사용 중인 아이디입니다.");
              } else {
                alert("사용 가능한 아이디입니다.");
              }
            }
          };
          xhr.send();
        } else if (field === "닉네임") {
          var nickname = document.querySelector('input[name="nickname"]').value;
          if (!nickname) {
            alert("닉네임을 먼저 입력하세요.");
            return;
          }
          var xhr = new XMLHttpRequest();
          xhr.open("GET", "CheckNicknameServlet?nickname=" + encodeURIComponent(nickname), true);
          xhr.onreadystatechange = function() {
            if (xhr.readyState === 4 && xhr.status === 200) {
              var isDuplicate = xhr.responseText.trim();
              if (isDuplicate === "true") {
                alert("이미 사용 중인 닉네임입니다.");
              } else {
                alert("사용 가능한 닉네임입니다.");
              }
            }
          };
          xhr.send();
        }
      }
      
      document.addEventListener('DOMContentLoaded', function() {
        // 각 요소 선택
        var passwordField = document.getElementById('password');
        var confirmField = document.getElementById('passwordConfirm');
        var errorSpan = document.getElementById('passwordError');
        var emailField = document.getElementById('email');
        var emailError = document.getElementById('emailError');
        var phoneField = document.getElementById('phone');
        var phoneError = document.getElementById('phoneError');
        var passwordRequirementError = document.getElementById('passwordRequirementError');
        var signupForm = document.getElementById('signupForm');

        // 비밀번호 일치 여부 검사 함수
        function checkPasswordMatch() {
          if (passwordField.value !== confirmField.value) {
            errorSpan.textContent = "불일치";
            errorSpan.style.color = "red";
            return false;
          } else {
            errorSpan.textContent = "일치";
            errorSpan.style.color = "blue";
            return true;
          }
        }

        // 비밀번호 요구사항 검사 함수 (8~16자, 특수문자 1개 이상)
        function checkPasswordRequirement() {
          var password = passwordField.value;
          var specialCharRegex = /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]+/;
          
          if (password.length < 8 || password.length > 16 || !specialCharRegex.test(password)) {
            passwordRequirementError.textContent = "비밀번호는 8~16자리이며, 특수문자를 포함해야 합니다.";
            passwordRequirementError.style.color = "red";
            return false;
          } else {
            passwordRequirementError.textContent = "사용 가능한 비밀번호입니다.";
            passwordRequirementError.style.color = "blue";
            return true;
          }
        }
        
        // 이메일 유효성 검사 (Gmail과 Naver만 허용)
        function checkEmail() {
          var email = emailField.value;
          // Gmail과 Naver 이메일만 허용하는 정규식
          var emailRegex = /^[a-zA-Z0-9._-]+@(gmail\.com|naver\.com)$/;
          
          if (!emailRegex.test(email)) {
            emailError.textContent = "Gmail이나 Naver 이메일만 사용 가능합니다.";
            emailError.style.color = "red";
            return false;
          } else {
            emailError.textContent = "올바른 이메일 형식입니다.";
            emailError.style.color = "blue";
            return true;
          }
        }
        
        // 전화번호 형식 검사 (하이픈 포함 필수)
        function checkPhoneLength() {
          var phone = phoneField.value;
          var phoneRegex = /^01[0-1|6-9]-\d{3,4}-\d{4}$/;
          
          if (!phoneRegex.test(phone)) {
            phoneError.textContent = "올바른 전화번호 형식이 아닙니다. (예: 010-1234-5678)";
            phoneError.style.color = "red";
            return false;
          } else {
            phoneError.textContent = "올바른 형식입니다.";
            phoneError.style.color = "blue";
            return true;
          }
        }

        // 키업 이벤트를 통해 실시간 검사
        passwordField.addEventListener('keyup', function() {
          checkPasswordMatch();
          checkPasswordRequirement();
        });
        confirmField.addEventListener('keyup', checkPasswordMatch);
        emailField.addEventListener('blur', checkEmail);
        phoneField.addEventListener('input', checkPhoneLength);
        
        // 전화번호 자동 하이픈 추가 기능은 제거
        // 사용자가 직접 하이픈을 입력하도록 함
        phoneField.addEventListener('blur', checkPhoneLength);
        emailField.addEventListener('blur', checkEmail);
        
        // 폼 제출 시 최종 유효성 검사
        signupForm.addEventListener('submit', function(e) {
          var isPasswordMatched = checkPasswordMatch();
          var isPasswordValid = checkPasswordRequirement();
          var isEmailValid = checkEmail();
          var isPhoneValid = checkPhoneLength();
          
          if (!isPasswordMatched || !isPasswordValid || !isEmailValid || !isPhoneValid) {
            e.preventDefault(); // 폼 제출 중단
            alert("입력 정보를 다시 확인해주세요.");
          }
        });
      });
    </script>
</head>
<body>
  <div class="login-container">
    <!-- 상단 타이틀 -->
    <h1 class="login-title">YUMMY JEJU</h1>
    <h2 class="login-header">회원가입</h2>
    
    <!-- 회원가입 폼 -->
    <form action="signup_Proc.jsp" method="post" id="signupForm">
    
      <!-- 이름 입력 -->
      <label for="username" class="custom-label">이름</label>
      <input type="text" class="input-field" name="username" placeholder="이름을 입력하세요" required>
      
      <!-- 아이디 입력과 중복확인 버튼 -->
      <label for="userid" class="custom-label">아이디</label>
      <div style="display: flex; align-items: center; gap: 10px;">
        <input type="text" class="input-field" name="userid" placeholder="아이디를 입력하세요" required style="flex: 1;">
        <button type="button" class="login-button" style="width: auto; padding: 12px 20px;" onclick="checkDuplicate('아이디')">중복확인</button>
      </div>
      
      <!-- 비밀번호 입력 -->
      <label for="password" class="custom-label">비밀번호</label>
      <input type="password" id="password" class="input-field" name="password" placeholder="비밀번호를 입력하세요 (8~16자, 특수문자 포함)" required>
      <span id="passwordRequirementError" class="error-message"></span>
      
      <!-- 비밀번호 확인 입력 -->
      <label for="passwordConfirm" class="custom-label">비밀번호 확인
        <span id="passwordError" class="error-message"></span>
      </label>
      <input type="password" id="passwordConfirm" class="input-field" name="passwordConfirm" placeholder="비밀번호를 한번 더 입력해주세요" required>
      
      <!-- 닉네임 입력과 중복확인 버튼 -->
      <label for="nickname" class="custom-label">닉네임</label>
      <div style="display: flex; align-items: center; gap: 10px;">
        <input type="text" class="input-field" name="nickname" placeholder="닉네임을 입력하세요" required style="flex: 1;">
        <button type="button" class="login-button" style="width: auto; padding: 12px 20px;" onclick="checkDuplicate('닉네임')">중복확인</button>
      </div>
      
      <!-- 이메일 입력 -->
      <label for="email" class="custom-label">이메일</label>
      <input type="email" id="email" class="input-field" name="email" placeholder="이메일을 입력하세요" required>
      <span id="emailError" class="error-message"></span>
      <div class="hint" style="font-size: 12px; color: #666; margin-top: 3px;"></div>
      
      <!-- 전화번호 입력 -->
      <label for="phone" class="custom-label">전화번호</label>
      <input type="tel" id="phone" class="input-field" name="phone" placeholder="전화번호를 입력하세요 (예: 010-1234-5678)" maxlength="13" required>
      <span id="phoneError" class="error-message"></span>
      <div class="hint" style="font-size: 12px; color: #666; margin-top: 3px;"></div>
      
      <!-- 회원가입 버튼 -->
      <button type="submit" class="login-button" style="margin-top:20px;">회원가입하기</button>
    </form>
    
    <!-- 로그인 페이지로 이동하는 링크 -->
    <div class="extra-links">
      <a href="login.jsp">로그인으로 이동</a>
    </div>
    
    <!-- 푸터 -->
    <div class="footer">
      © YUMMY JEJU Korea
    </div>
  </div>
</body>
</html>