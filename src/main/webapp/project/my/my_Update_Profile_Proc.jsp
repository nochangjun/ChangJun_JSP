<%@page import="project.MemberBean"%>
<%@ page  contentType="text/html; charset=UTF-8"%>
<%@ page import="java.io.*, com.oreilly.servlet.*, com.oreilly.servlet.multipart.*, java.util.*, project.MemberMgr" %>
<%
    request.setCharacterEncoding("UTF-8");
    String savePath = application.getRealPath("/upload/profile");
    
    // 폴더 없으면 생성
    File uploadDir = new File(savePath);
    if (!uploadDir.exists()) {
        uploadDir.mkdirs();
    }
    
    int maxSize = 5 * 1024 * 1024; // 5MB

    MultipartRequest multi = new MultipartRequest(request, savePath, maxSize, "UTF-8", new DefaultFileRenamePolicy());

    String id = (String) session.getAttribute("idKey");
    if (id == null) {
        response.sendRedirect("../login/login.jsp");
        return;
    }

    String nickname = multi.getParameter("userNickname");
    String phone = multi.getParameter("userPhone");
    String email = multi.getParameter("userEmail");
    String resetImageFlag = multi.getParameter("resetImageFlag");
    String filename = null;

    if ("true".equals(resetImageFlag)) {
        MemberMgr mgrTemp = new MemberMgr();
        MemberBean member = mgrTemp.getMember(id);
        String existingImage = member.getMember_image();
        
        if (existingImage != null && !existingImage.isEmpty()) {
            File oldFile = new File(savePath, existingImage);
            if (oldFile.exists()) oldFile.delete(); // 실제 파일 삭제
        }

        filename = null; // DB에 저장할 이미지 없음
    } else {
        filename = multi.getFilesystemName("imageFile");
        if (filename == null) {
            MemberMgr mgrTemp = new MemberMgr();
            MemberBean member = mgrTemp.getMember(id);
            filename = member.getMember_image();  // 기존 파일 유지
        }
    }
    
    MemberMgr mgr = new MemberMgr();
    boolean updateSuccess = mgr.updateMemberProfile(id, nickname, phone, email, filename);

    if (updateSuccess) {
		%>
		    <script>
		        alert("회원정보가 성공적으로 수정되었습니다.");
		        location.href = "my_Update_Profile.jsp";
		    </script>
		<%
    } else {
		%>
		    <script>
		        alert("회원정보 수정에 실패했습니다.");
		        history.back();
		    </script>
		<%
    }
%>
