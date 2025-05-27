package project;

import java.io.File;
import java.io.IOException;
import java.util.UUID;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import project.RestaurantMgr;

@WebServlet("/project/StoreRegisterServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,     // 1MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB
    maxRequestSize = 1024 * 1024 * 20    // 20MB
)
public class StoreRegisterServlet extends HttpServlet {
	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
	        throws ServletException, IOException {

	    request.setCharacterEncoding("UTF-8");

	    // ✅ 세션에서 로그인한 회원의 ID 가져오기
	    HttpSession session = request.getSession();
	    String member_id = (String) session.getAttribute("idKey");
	    if (member_id == null) {
	        // 로그인 안 되어 있으면 메인으로 리다이렉트
	        response.sendRedirect(request.getContextPath() + "/login.jsp");
	        return;
	    }

	    // 📥 파라미터 수집
	    String rst_name = request.getParameter("storeName");
	    String rst_address = request.getParameter("address");
	    double rst_lat = Double.parseDouble(request.getParameter("latitude"));
	    double rst_long = Double.parseDouble(request.getParameter("longitude"));
	    String regionLabel = request.getParameter("city");
	    String region2Label = request.getParameter("town");
	    String rst_introduction = request.getParameter("description");
	    String rst_phonenumber = request.getParameter("phone");
	    String rst_tag = request.getParameter("hashtag");

	    // 📸 파일 처리
	    Part filePart = request.getPart("imageFile");
	    String uploadPath = request.getServletContext().getRealPath("/upload/restaurant");
	    File uploadDir = new File(uploadPath);
	    if (!uploadDir.exists()) uploadDir.mkdirs();

	    String fileName = UUID.randomUUID().toString() + "_" + filePart.getSubmittedFileName();
	    filePart.write(uploadPath + File.separator + fileName);
	    String imgpath = "/upload/restaurant/" + fileName;

	    // 🫘 Bean 구성
	    RestaurantBean bean = new RestaurantBean();
	    bean.setRst_name(rst_name);
	    bean.setRst_address(rst_address);
	    bean.setRst_lat(rst_lat);
	    bean.setRst_long(rst_long);
	    bean.setRegionLabel(regionLabel);
	    bean.setRegion2Label(region2Label);
	    bean.setRst_introduction(rst_introduction);
	    bean.setRst_phonenumber(rst_phonenumber);
	    bean.setRst_tag(rst_tag);
	    bean.setImgpath(imgpath);
	    bean.setMember_id(member_id);  // ✅ member_id 저장

	    // DB 저장
	    RestaurantMgr mgr = new RestaurantMgr();
	    mgr.insertRestaurant(bean);

	    // ✅ 메시지를 세션에 저장하고 리다이렉트
	    session.setAttribute("storeSuccessMsg", "식당 등록이 완료되었습니다. 관리자 승인을 기다려주세요.");
	    response.sendRedirect(request.getContextPath() + "/project/main.jsp");
	}
}

