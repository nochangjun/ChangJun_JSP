package project;

public class EvtParticipantsBean {
    private int evt_id;
    private String evt_title;
    private String evt_content;
    private String evt_created_at;
    private String admin_id;

    public int getEvt_id() {
        return evt_id;
    }
    public void setEvt_id(int evt_id) {
        this.evt_id = evt_id;
    }

    public String getEvt_title() {
        return evt_title;
    }
    public void setEvt_title(String evt_title) {
        this.evt_title = evt_title;
    }

    public String getEvt_content() {
        return evt_content;
    }
    public void setEvt_content(String evt_content) {
        this.evt_content = evt_content;
    }

    public String getEvt_created_at() {
        return evt_created_at;
    }
    public void setEvt_created_at(String evt_created_at) {
        this.evt_created_at = evt_created_at;
    }

    public String getAdmin_id() {
        return admin_id;
    }
    public void setAdmin_id(String admin_id) {
        this.admin_id = admin_id;
    }
}
