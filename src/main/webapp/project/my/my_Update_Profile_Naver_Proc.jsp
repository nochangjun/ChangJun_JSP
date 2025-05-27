<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="project.MemberMgr, project.MemberBean" %>
<%
    request.setCharacterEncoding("UTF-8");

    String id = (String) session.getAttribute("idKey");
    if (id == null) {
        response.sendRedirect("../login/login.jsp");
        return;
    }

    String nickname = request.getParameter("userNickname");

    if (nickname == null || nickname.trim().isEmpty()) {
%>
    <script>
        alert("닉네임을 입력해주세요.");
        location.href = "my_Update_Profile_Naver.jsp";
    </script>
<%
        return;
    }

    MemberMgr mgr = new MemberMgr();
    MemberBean member = mgr.getMember(id);
    
 	// 기존 정보로 유지하면서 닉네임만 변경
    String phone = member.getMember_phone();
    String email = member.getMember_email();
    String image = member.getMember_image();
    
    boolean result = mgr.updateMemberProfile(id, nickname, phone, email, image);  // 휴대폰/이메일/이미지는 수정 안함
%>
<script>
    alert("<%= result ? "닉네임이 성공적으로 수정되었습니다." : "닉네임 수정에 실패했습니다." %>");
    location.href = "my_Update_Profile_Naver.jsp";
</script>