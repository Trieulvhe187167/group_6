package scheduler;

import dal.RoomDAO;
import model.Room;
import java.util.List;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
public class RoomHoldScheduler {

    private final RoomDAO roomDAO = new RoomDAO();

    @Scheduled(fixedDelay = 60000)
    public void releaseExpiredHolds() {
        List<Room> heldRooms = roomDAO.getRoomsByStatus("HELD");
        long now = System.currentTimeMillis();
        for (Room room : heldRooms) {
            java.sql.Timestamp holdUntil = room.getHoldUntil();
            if (holdUntil != null && holdUntil.getTime() < now) {
                roomDAO.updateRoomStatus(room.getId(), "AVAILABLE", null);
            }
        }
    }
}   