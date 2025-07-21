package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Iterator;
import java.sql.Date;
import model.CartItem;
import model.Room;
import model.RoomType;
import dal.RoomDAO;
import dal.RoomTypeDAO;

@WebServlet(name="CartServlet", urlPatterns = {"/CartServlet"})
public class CartServlet extends HttpServlet {

    private final RoomDAO roomDAO = new RoomDAO();
    private final RoomTypeDAO roomTypeDAO = new RoomTypeDAO();

    private void releaseExpiredHolds(HttpSession session) {
        List<CartItem> cart = (List<CartItem>) session.getAttribute("cart");
        if (cart == null) return;

        long now = System.currentTimeMillis();
        Iterator<CartItem> iter = cart.iterator();
        while (iter.hasNext()) {
            CartItem item = iter.next();
            if (item.getHoldUntil() > 0 && now > item.getHoldUntil()) {
                for (int roomId : item.getRoomIds()) {
                    roomDAO.updateRoomStatus(roomId, "AVAILABLE");
                }
                iter.remove();
            }
        }
        session.setAttribute("cart", cart);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        releaseExpiredHolds(session);
        String action = request.getParameter("action");
        if ("add".equals(action)) {
            try {
                int roomTypeId = Integer.parseInt(request.getParameter("roomTypeId"));
                String roomTypeName = request.getParameter("roomTypeName");
                BigDecimal price = new BigDecimal(request.getParameter("price"));
                String checkIn = request.getParameter("checkIn");
                String checkOut = request.getParameter("checkOut");
                int quantity = 1;
                try {
                    quantity = Integer.parseInt(request.getParameter("quantity"));
                } catch (Exception e) {
                    // ignore, default 1
                }

                Date inDate = Date.valueOf(checkIn);
                Date outDate = Date.valueOf(checkOut);

                List<CartItem> cart = (List<CartItem>) session.getAttribute("cart");
                if (cart == null) {
                    cart = new ArrayList<>();
                }

                CartItem existing = null;
                for (CartItem ci : cart) {
                    if (ci.getRoomTypeId() == roomTypeId
                            && ci.getCheckIn().equals(checkIn)
                            && ci.getCheckOut().equals(checkOut)) {
                        existing = ci;
                        break;
                    }
                }

                List<Room> available = roomDAO.getAvailableRoomsByTypeAndDate(roomTypeId, inDate, outDate);

                // Exclude rooms that are already held in the current cart in case
                // the status update failed or they were just held a moment ago
                java.util.Set<Integer> heldIds = new java.util.HashSet<>();
                for (CartItem ci : cart) {
                    heldIds.addAll(ci.getRoomIds());
                }
                available.removeIf(rm -> heldIds.contains(rm.getId()));

                if (available.size() < quantity) {
                    // not enough rooms, ignore for simplicity
                } else {
                    RoomType rt = roomTypeDAO.getRoomTypesById(roomTypeId);
                    int capacity = (rt != null) ? rt.getCapacity() : 1;
                    List<Integer> reserved = new ArrayList<>();
                    long holdUntil = System.currentTimeMillis() + 10 * 60 * 1000;
                    for (int i = 0; i < quantity; i++) {
                        Room rm = available.get(i);
                         roomDAO.updateRoomStatus(rm.getId(), "HELD", new java.sql.Timestamp(holdUntil));
                        reserved.add(rm.getId());
                    }
          
                    
                    if (existing != null) {
                        existing.getRoomIds().addAll(reserved);
                        existing.setQuantity(existing.getQuantity() + quantity);
                        existing.setHoldUntil(holdUntil);
                    } else {
                        CartItem ci = new CartItem(roomTypeId, roomTypeName, price, checkIn, checkOut,
                                quantity, reserved, holdUntil,
                                1, 0, capacity);
                        cart.add(ci);
                    }
                }

                session.setAttribute("cart", cart);
            } catch (Exception e) {
                // ignore errors for simplicity
            }
            // Redirect back to the referring page with a success flag
            String referer = request.getHeader("referer");
            if (referer == null || referer.contains("CartServlet")) {
                response.sendRedirect("CartServlet");
            } else {
                if (referer.contains("?")) {
                    referer += "&added=1";
                } else {
                    referer += "?added=1";
                }
                response.sendRedirect(referer);
            }
            return;
        } else if ("remove".equals(action)) {
            int index = Integer.parseInt(request.getParameter("index"));
            List<CartItem> cart = (List<CartItem>) session.getAttribute("cart");
            if (cart != null && index >= 0 && index < cart.size()) {
                CartItem removed = cart.remove(index);
                if (removed != null) {
                    for (int roomId : removed.getRoomIds()) {
                        roomDAO.updateRoomStatus(roomId, "AVAILABLE");
                    }
                }
                session.setAttribute("cart", cart);
            }
            response.sendRedirect("CartServlet");
            return;
        }

        request.getRequestDispatcher("/jsp/cart.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}