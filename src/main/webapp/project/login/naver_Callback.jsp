<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
  <title>네이버 로그인 콜백</title>
</head>
<body>
<script src="https://static.nid.naver.com/js/naveridlogin_js_sdk_2.0.0.js"></script>
<script>
  const naverLogin = new naver.LoginWithNaverId({
    clientId: "rwUIgM_3Jnf0N0KycmjE",
    callbackUrl: "http://113.198.238.109/myapp/project/login/naver_Callback.jsp",
   
    isPopup: false,
    callbackHandle: true
  });

  naverLogin.init();

  window.addEventListener('load', function () {
    naverLogin.getLoginStatus(function(status) {
      if (status) {
        const realName  = naverLogin.user.getName();
        const email = naverLogin.user.getEmail();
        const nickname = naverLogin.user.getNickName();
        const phone = typeof naverLogin.user.getMobile === 'function'
            ? naverLogin.user.getMobile()
            : (naverLogin.user._profileObj && naverLogin.user._profileObj.mobile) || '';
        const profileImage = naverLogin.user.getProfileImage();

     	// ② 로그인 직전 URL 꺼내기
        const redirectUrl = sessionStorage.getItem('originalUrl') || '../main.jsp';
        console.log("naver_Callback redirect URL:", redirectUrl);
        
        const redirectParam = "<%= request.getParameter("redirect") != null ? request.getParameter("redirect") : "" %>";
        console.log("서버에서 받은 redirectParam:", redirectParam);
        
        // 폼 생성 후 자동 전송
        const form = document.createElement('form');
        form.method = 'POST';
        form.action = 'naver_Proc.jsp';

        [
            ['realName',     realName],
            ['email',        email],
            ['nickname',     nickname],
            ['phone',        phone],
            ['profileImage', profileImage],
            ['redirect',     redirectUrl]
        ].forEach(([name, value]) => {
            const inp = document.createElement('input');
            inp.type  = 'hidden';
            inp.name  = name;
            inp.value = value;
            form.appendChild(inp);
        });

        document.body.appendChild(form);
        form.submit();
      } else {
        alert("네이버 로그인 실패");
        location.href = "login.jsp";
      }
    });
  });
</script>
</body>
</html>
