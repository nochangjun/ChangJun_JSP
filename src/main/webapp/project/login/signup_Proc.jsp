<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="project.MemberMgr, project.MemberBean" %>
<%
    request.setCharacterEncoding("UTF-8");
    
    // 폼에서 전달받은 값 추출
    String userid = request.getParameter("userid");         // 아이디 (member_id)
    String password = request.getParameter("password");         // 비밀번호
    String passwordConfirm = request.getParameter("passwordConfirm"); // 비밀번호 확인
    String memberName = request.getParameter("username");       // 이름 (member_name)
    String nickname = request.getParameter("nickname");         // 닉네임 (member_nickname)
    String email = request.getParameter("email");               // 이메일
    String phone = request.getParameter("phone");               // 전화번호
    
    // 비밀번호 확인 검사
    if (!password.equals(passwordConfirm)) {
        out.println("<script>alert('비밀번호가 일치하지 않습니다.'); history.back();</script>");
        return;
    }
    
 	// MemberMgr 인스턴스 생성
    MemberMgr mgr = new MemberMgr();
    
    // 아이디 중복 검사 (중복이면 메시지 출력)
    if(mgr.checkId(userid)) {
        out.println("<script>alert('이미 사용 중인 아이디입니다.'); history.back();</script>");
        return;
    }
    
    // 닉네임 중복 검사 (중복이면 메시지 출력)
    if(mgr.checkNickname(nickname)) {
        out.println("<script>alert('이미 사용 중인 닉네임입니다.'); history.back();</script>");
        return;
    }
    
    // MemberBean 객체 생성 및 값 설정
    MemberBean bean = new MemberBean();
    bean.setMember_id(userid);
    bean.setMember_pwd(password); // 실제 서비스에서는 암호화 필요
    bean.setMember_name(memberName);
    bean.setMember_phone(phone);
    bean.setMember_email(email);
    bean.setMember_nickname(nickname);
    bean.setMember_image(""); // 기본값, 이미지 정보가 없는 경우 빈 문자열로 처리

    // MemberMgr를 이용하여 DB에 회원정보 삽입
    boolean result = mgr.insertMember(bean);
    
    if (result) {
        out.println("<script>alert('회원가입이 완료되었습니다.'); location.href='login.jsp';</script>");
    } else {
        out.println("<script>alert('회원가입에 실패하였습니다.'); history.back();</script>");
    }
%>
