<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>YUMMY JEJU - 관리자 비밀번호 찾기</title>
  <link rel="stylesheet" href="../css/login.css">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
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
</body>
</html>