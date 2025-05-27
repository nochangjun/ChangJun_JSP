<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:useBean id="login" class="project.MemberBean" scope="session"/>
<%
		String id = (String)session.getAttribute("idKey");
		String url = request.getParameter("url");
		String redirect = request.getParameter("redirect");
		if (redirect == null || redirect.trim().equals("")) {
		    redirect = "/project/main.jsp"; // 기본값 설정
		}
		
		
		// loginType 파라미터를 읽어서 없으면 기본값 "normal"을 설정
	    String loginTypeParam = request.getParameter("loginType");
	    if(loginTypeParam == null || loginTypeParam.isEmpty()){
	         loginTypeParam = "normal";
	    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>YUMMY JEJU</title>
	<link rel="stylesheet" href="../css/login.css">
  
  	<script>
  	
	    (function(){
	      if (!sessionStorage.getItem('originalUrl')) {
	        sessionStorage.setItem('originalUrl', document.referrer);
	        console.log("originalUrl 저장됨 : ", document.referrer);
	      }
	    })();
 	</script>
  

	

  
	<script>
		function switchTab(tabType) {
		  const tabs = document.querySelectorAll('.tab');
		  tabs.forEach(tab => tab.classList.remove('active'));
		  
		  if (tabType === 'normal') {
		    tabs[0].classList.add('active');
		    document.getElementById('member-links').style.display = 'block';
		    document.getElementById('admin-links').style.display = 'none';
		    document.getElementById('social-login-container').style.display = 'block';
		  } else if (tabType === 'partner') {
		    tabs[1].classList.add('active');
		    document.getElementById('member-links').style.display = 'none';
		    document.getElementById('admin-links').style.display = 'block';
		    document.getElementById('social-login-container').style.display = 'none';
		  }
		  
		  document.getElementById('loginType').value = tabType;
		}
	</script>
</head>
<body>
  <div class="login-container">
    <h1 class="login-title">
    	<a href="../main.jsp" style="text-decoration: none; color: inherit;">YUMMY JEJU</a>
    </h1>
    
    <h2 class="login-header">로그인</h2>
    
    <div class="tab-container">
      <div class="tab active" onclick="switchTab('normal')">회원</div>
      <div class="tab" onclick="switchTab('partner')">관리자</div>
    </div>
    
    <form action="login_Proc.jsp" method="post" id="loginForm">
	      <input type="hidden" name="loginType" id="loginType" value="<%= loginTypeParam %>">
	      <input type="hidden" name="redirect" value="<%= request.getParameter("url") != null ? request.getParameter("url") : "" %>">
	      
	      <input type="text" class="input-field" style="margin-bottom: 10px;" name="userid" placeholder="아이디를 입력해주세요" required>
	      <input type="password" class="input-field" style="margin-bottom: 10px;" name="password" placeholder="비밀번호를 입력해주세요" required>
	      
	      <div class="checkbox-container">
		        <input type="checkbox" id="rememberMe" name="rememberMe">
		        <label for="rememberMe">로그인 상태 유지</label>
	      </div>
	      
	      <!-- 로그인 성공 후 돌아갈 페이지 경로 전달 -->
	      <input type="hidden" name="redirect" value="<%= redirect %>">
	      
	      <button type="submit" class="login-button" style="margin-top:10px;">로그인하기</button>
	      
	      <!-- 회원용 추가 링크: 회원가입, ID 찾기, 비밀번호 찾기 -->
	      <div id="member-links" class="extra-links">
		        <a href="signup.jsp">회원가입</a> |
		        <a href="member_Find_Id.jsp">ID 찾기</a> |
		        <a href="member_Find_Pwd.jsp">비밀번호 찾기</a>
	      </div>
	      
	      <!-- 관리자용 추가 링크: ID 찾기, 비밀번호 찾기 (회원가입 링크 제외) -->
	      <div id="admin-links" class="extra-links" style="display: none;">
		        <a href="admin_Find_Id.jsp">ID 찾기</a> |
		        <a href="admin_Find_Pwd.jsp">비밀번호 찾기</a>
	      </div>
    </form>
    
    <!-- 회원용 소셜 로그인 버튼 -->
    <div id="social-login-container">
      <button id="naver-login-btn" type="button" class="social-login-button naver-button" style="margin-top:20px;">네이버로 로그인/회원가입</button>
    </div>
    
    <!-- 홈페이지로 가기 버튼 -->
	<div style="text-align:center; margin-top:20px;">
	  <a href="../main.jsp" style="color: #555; font-size: 14px; text-decoration: none;">
	    🏠 홈페이지로 가기
	  </a>
	</div>
    
    <div class="footer">
      © YUMMY JEJU Korea
    </div>
  </div>
  
  <script>
      window.onload = function(){
           var loginType = '<%= loginTypeParam %>';
           switchTab(loginType);
      }
  </script>
  
  
    	<!-- 네이버 로그인 SDK 로드 (네이버 로그인 API 제공 URL 참고) -->
	<script src="https://static.nid.naver.com/js/naveridlogin_js_sdk_2.0.2.js"
		charset="utf-8"></script>
		
  	<script>
	  document.addEventListener("DOMContentLoaded", function() {
		  console.log("✅ DOMContentLoaded 실행됨");
		  
		const naverLogin = new naver.LoginWithNaverId({
	      clientId: "rwUIgM_3Jnf0N0KycmjE", // 네이버 CLIENT ID 확인
	      callbackUrl: "http://113.198.238.109/myapp/project/login/naver_Callback.jsp",
	      isPopup: false, 
	      callbackHandle: true
	    });
	    
	   naverLogin.init();
	       
	   const btn = document.getElementById("naver-login-btn");
	    if (btn) {
	      btn.addEventListener("click", () => {
	        
	          const authUrl = naverLogin.generateAuthorizeUrl({
	            scope: 'name,email,profile_image,nickname,mobile',
	            auth_type: 'reauthenticate'
	          });
	          
	          console.log(">> 강제 재인증 authUrl:", authUrl);
	          location.href = authUrl; 
	        
	      });
	    } else {
	        console.warn("🚨 버튼이 존재하지 않습니다! ID 확인 필요");
	      }
	  });
	</script>
</body>
</html>
