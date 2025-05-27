package project;

import java.io.*;
import java.util.UUID;
import javax.servlet.*;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/project/admin/eventRegisterProc")
@MultipartConfig
public class EventRegisterServlet extends HttpServlet {
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		request.setCharacterEncoding("UTF-8");

		HttpSession session = request.getSession();
		String adminId = (String) session.getAttribute("admin_id");

		if (adminId == null) {
			response.sendRedirect("../login/login.jsp");
			return;
		}

		String title = request.getParameter("title");
		String content = request.getParameter("content");
		if (content == null || content.trim().isEmpty()) {
		    content = "";  // ✅ 내용이 없을 경우 빈 문자열로 대체
		}
		String startDate = request.getParameter("start_date");
		String endDate = request.getParameter("end_date");

		System.out.println("📥 입력값:");
		System.out.println("title = " + title);
		System.out.println("content = " + content);
		System.out.println("start = " + startDate);
		System.out.println("end = " + endDate);
		System.out.println("admin_id = " + adminId);

		String imageUrl = null;
		Part imagePart = request.getPart("image");

		if (imagePart != null && imagePart.getSize() > 0) {
			String fileName = UUID.randomUUID().toString() + "_" + imagePart.getSubmittedFileName();
			String uploadPath = getServletContext().getRealPath("/upload/event");

			File uploadDir = new File(uploadPath);
			if (!uploadDir.exists()) uploadDir.mkdirs();

			String fullPath = uploadPath + File.separator + fileName;
			imagePart.write(fullPath);
			imageUrl = "upload/event/" + fileName;

			System.out.println("✅ 이미지 저장 완료: " + imageUrl);
		}

		EventBean bean = new EventBean();
		bean.setTitle(title);
		bean.setContent(content);
		bean.setImageUrl(imageUrl);
		bean.setStartDate(startDate);
		bean.setEndDate(endDate);
		bean.setAdminId(adminId);

		EventMgr mgr = new EventMgr();
		boolean result = mgr.insertEvent(bean);

		if (result) {
			System.out.println("✅ 이벤트 등록 성공");
			response.sendRedirect("admin_Event_Register.jsp?result=success");
		} else {
			System.out.println("❌ 이벤트 등록 실패");
			response.sendRedirect("admin_Event_Register.jsp?result=fail");
		}
	}
}
