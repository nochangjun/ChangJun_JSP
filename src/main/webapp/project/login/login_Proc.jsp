<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="project.MemberMgr" %>
<%
	request.setCharacterEncoding("UTF-8");

	String loginType = request.getParameter("loginType");
	String id = request.getParameter("userid");
	String pwd = request.getParameter("password");
	String rememberMe = request.getParameter("rememberMe");
	String redirect = request.getParameter("redirect");	// 로그인 후 돌아갈 주소
	System.out.print(redirect);

	
	MemberMgr mgr = new MemberMgr();
	boolean loginSuccess = false;
	
	if("partner".equals(loginType)) {
		loginSuccess = mgr.loginAdmin(id, pwd); // 관리자 로그인 처리
		if (loginSuccess) {
			session.setAttribute("admin_id", id); // 관리자용 세션 저장
		}
	} else {
		loginSuccess = mgr.loginMember(id, pwd); // 일반 회원 로그인 처리
	}
	
	if(loginSuccess) {
		// 로그인 성공 시 세션에 id 저장
		session.setAttribute("idKey", id);
		session.setAttribute("loginType", loginType); // 관리자/회원 구분용
		
		// 로그인 상태 유지 옵션
		if("on".equals(rememberMe)) {
			Cookie idCookie = new Cookie("id", id);
			Cookie typeCookie = new Cookie("loginType", loginType);
			
			idCookie.setMaxAge(60 * 60 * 24 * 7); // 7일간 유지
			typeCookie.setMaxAge(60 * 60 * 24 * 7);
			
			 idCookie.setPath("/");           // ✅ 모든 경로에서 사용 가능하도록
			    typeCookie.setPath("/"); 
			
			response.addCookie(idCookie);
			response.addCookie(typeCookie);
		}

		// 페이지 이동 처리
		if("partner".equals(loginType)) {
			response.sendRedirect("../admin/admin_Main.jsp"); // 관리자 페이지
		} else {
			// redirect 파라미터가 있을 경우 해당 위치로 이동
			if (redirect != null && !redirect.trim().equals("") && !"null".equals(redirect.trim())) {
				redirect = java.net.URLDecoder.decode(redirect, "UTF-8");
				response.sendRedirect(redirect);
			} else {
				response.sendRedirect("../main.jsp"); // 기본 홈으로 이동
			}
		}
	} else {
		// 로그인 실패 시 메시지와 함께 다시 로그인 페이지로 이동
		out.println("<script>alert('아이디 또는 비밀번호가 잘못되었습니다. 다시 시도해 주세요.'); location.href='login.jsp';</script>");
	}
%>
