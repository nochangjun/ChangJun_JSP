package project;

import java.io.IOException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/admin/InquiryDetailServlet")
public class InquiryDetailServlet extends HttpServlet {
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		 String inqIdParam = request.getParameter("inq_id");
	        if (inqIdParam == null) {
	            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "문의 ID가 없습니다.");
	            return;
	        }

	        int inqId = Integer.parseInt(inqIdParam);
	        InquiryMgr mgr = new InquiryMgr();
	        InquiryBean inquiry = mgr.getInquiryWithMember(inqId);

	        if (inquiry == null) {
	            response.sendError(HttpServletResponse.SC_NOT_FOUND, "문의 정보를 찾을 수 없습니다.");
	            return;
	        }

	        request.setAttribute("inquiry", inquiry);
	        RequestDispatcher dispatcher = request.getRequestDispatcher("/project/admin/admin_Inquiry_Detail.jsp");
	        dispatcher.forward(request, response);
	    }

}
