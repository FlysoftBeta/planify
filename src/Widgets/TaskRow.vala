public class Widgets.TaskRow : Gtk.ListBoxRow {
    public Objects.Task task { get; construct; }

    private Gtk.FlowBox labels_flowbox;
    private Gtk.CheckButton checked_button;
    public Gtk.Label name_label;
    private Gtk.Entry name_entry;
    private Gtk.Button close_button;
    private Gtk.Button remove_button;

    private Gtk.Box when_preview_box;
    private Gtk.Image when_preview_icon;
    private Gtk.Label when_preview_label;

    private Gtk.Box reminder_preview_box;
    private Gtk.Label reminder_preview_label;
    private Gtk.Box project_preview_box;

    private Gtk.TextView note_view;
    private Gtk.Revealer bottom_box_revealer;
    private Gtk.Grid main_grid;
    private Gtk.EventBox name_eventbox;
    private Gtk.Grid checklist_preview;
    private Gtk.ListBox checklist;

    private Gtk.Box top_box;
    private Gtk.Revealer remove_revealer;
    private Gtk.Revealer close_revealer;

    public Gtk.Box project_box;

    private Widgets.WhenButton when_button;

    /*
    private const Gtk.TargetEntry targetEntriesProjectRow [] = {
		{ "ProjectRow", Gtk.TargetFlags.SAME_APP, 0 }
	};
    */

    public signal void on_signal_update ();
    public TaskRow (Objects.Task _task) {
        Object (
            task: _task,
            margin_end: 24
        );
    }

    construct {
        get_style_context ().add_class ("task");

        checked_button = new Gtk.CheckButton ();

        if (task.checked == 1) {
            checked_button.active = true;
        } else {
            checked_button.active = false;
        }

        tooltip_text = task.content;

        name_label = new Gtk.Label (task.content);
        name_label.halign = Gtk.Align.START;
        name_label.ellipsize = Pango.EllipsizeMode.END;
        name_label.use_markup = true;
        name_label.margin_bottom = 1;
        name_label.margin_start = 6;
        name_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);

        name_entry = new Gtk.Entry ();
        name_entry.text = task.content;
        name_entry.hexpand = true;
        name_entry.margin_bottom = 1;
        name_entry.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        name_entry.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
        name_entry.get_style_context ().add_class ("planner-entry");
        name_entry.get_style_context ().add_class (Gtk.STYLE_CLASS_VIEW);
        name_entry.no_show_all = true;

        close_button = new Gtk.Button.from_icon_name ("window-close-symbolic", Gtk.IconSize.MENU);
        close_button.height_request = 24;
        close_button.width_request = 24;
        close_button.get_style_context ().add_class ("button-close");

        close_revealer = new Gtk.Revealer ();
        close_revealer.transition_type = Gtk.RevealerTransitionType.CROSSFADE;
        close_revealer.add (close_button);
        close_revealer.reveal_child = false;
        close_revealer.valign = Gtk.Align.START;
        close_revealer.halign = Gtk.Align.END;

        when_preview_icon = new Gtk.Image ();
        when_preview_icon.gicon = new ThemedIcon ("office-calendar-symbolic");
        when_preview_icon.pixel_size = 16;

        when_preview_label = new Gtk.Label ("Today");
        when_preview_label.get_style_context ().add_class ("h3");

        when_preview_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        when_preview_box.pack_start (when_preview_icon, false, false, 0);
        when_preview_box.pack_start (when_preview_label, false, false, 3);

        var reminder_preview_icon = new Gtk.Image ();
        reminder_preview_icon.gicon = new ThemedIcon ("notification-new-symbolic");
        reminder_preview_icon.pixel_size = 16;

        reminder_preview_label = new Gtk.Label ("06:48");
        reminder_preview_label.get_style_context ().add_class ("h3");

        reminder_preview_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        reminder_preview_box.pack_start (reminder_preview_icon, false, false, 0);
        reminder_preview_box.pack_start (reminder_preview_label, false, false, 3);

        if (task.when_date_utc == "") {
            when_preview_box.no_show_all = true;
            when_preview_box.visible = false;
        }

        if (task.has_reminder == 0) {
            reminder_preview_box.no_show_all = true;
            reminder_preview_box.visible = false;
        }

        var project_preview_icon = new Gtk.Image ();
        project_preview_icon.gicon = new ThemedIcon ("mail-unread-symbolic");
        project_preview_icon.get_style_context ().add_class ("proyect-%i".printf (task.project_id));
        project_preview_icon.pixel_size = 16;

        var project_preview_label = new Gtk.Label (null);
        project_preview_label.get_style_context ().add_class ("h3");

        project_preview_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        project_preview_box.pack_start (project_preview_icon, false, false, 0);
        project_preview_box.pack_start (project_preview_label, false, false, 3);

        if (task.is_inbox == 1) {
            project_preview_label.label = _("Inbox");
        } else {
            var project = Application.database.get_project (task.project_id);
            project_preview_label.label = project.name;
        }

        var previews_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        previews_box.pack_start (name_label, false, false, 0);
        previews_box.pack_end (project_preview_box, false, false, 0);
        previews_box.pack_end (reminder_preview_box, false, false, 3);
        previews_box.pack_end (when_preview_box, false, false, 3);

        name_eventbox = new Gtk.EventBox ();
        name_eventbox.add_events (Gdk.EventMask.ENTER_NOTIFY_MASK | Gdk.EventMask.LEAVE_NOTIFY_MASK);
        name_eventbox.add (previews_box);

        top_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        top_box.hexpand = true;
        top_box.pack_start (checked_button, false, false, 0);
        top_box.pack_start (name_eventbox, true, true, 0);
        top_box.pack_start (name_entry, true, true, 6);

        note_view = new Gtk.TextView ();
        note_view.opacity = 0.8;
		note_view.set_wrap_mode (Gtk.WrapMode.WORD);
        note_view.height_request = 50;
        note_view.margin_start = 36;
        note_view.margin_end = 12;
		note_view.buffer.text = task.note;
        note_view.get_style_context ().add_class ("note-view");

        var note_view_placeholder_label = new Gtk.Label (_("Note"));
        note_view_placeholder_label.opacity = 0.65;
        note_view.add (note_view_placeholder_label);

        if (note_view.buffer.text != "") {
            note_view_placeholder_label.visible = false;
            note_view_placeholder_label.no_show_all = true;
        }

        var note_eventbox = new Gtk.EventBox ();
        note_eventbox.add (note_view);

        checklist = new Gtk.ListBox  ();
        checklist.activate_on_single_click = true;
        checklist.get_style_context ().add_class ("view");
        checklist.selection_mode = Gtk.SelectionMode.SINGLE;

        string[] checklist_array = task.checklist.split (";");

        foreach (string str in checklist_array) {
            string check_name = str.substring (1, -1);
            bool check_active = false;

            if (str.substring (0, 1) == "0") {
                check_active = false;
            } else {
                check_active = true;
            }

            var row = new Widgets.CheckRow (check_name, check_active);
            checklist.add (row);
	    }

        checklist.show_all ();

        var checklist_button = new Gtk.CheckButton ();
        checklist_button.get_style_context ().add_class ("planner-radio-disable");
        checklist_button.sensitive = false;

        var checklist_entry = new Gtk.Entry ();
        checklist_entry.hexpand = true;
        checklist_entry.margin_bottom = 1;
        checklist_entry.max_length = 50;
        checklist_entry.placeholder_text = _("Checklist");
        checklist_entry.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        checklist_entry.get_style_context ().add_class (Gtk.STYLE_CLASS_VIEW);
        checklist_entry.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
        checklist_entry.get_style_context ().add_class ("planner-entry");

        var checklist_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        checklist_box.pack_start (checklist_button, false, false, 0);
        checklist_box.pack_start (checklist_entry, true, true, 6);

        var checklist_grid = new Gtk.Grid ();
        checklist_grid.margin_start = 36;
        checklist_grid.margin_end = 12;
        checklist_grid.orientation = Gtk.Orientation.VERTICAL;
        checklist_grid.add (checklist);
        checklist_grid.add (checklist_box);

        labels_flowbox = new Gtk.FlowBox ();
        labels_flowbox.selection_mode = Gtk.SelectionMode.NONE;
        labels_flowbox.margin_start = 6;
        labels_flowbox.height_request = 38;
        labels_flowbox.expand = true;

        var labels_flowbox_revealer = new Gtk.Revealer ();
        labels_flowbox_revealer.margin_start = 22;
        labels_flowbox_revealer.margin_top = 6;
        labels_flowbox_revealer.add (labels_flowbox);
        labels_flowbox_revealer.reveal_child = false;

        string[] labels_array = task.labels.split (";");

        foreach (string id in labels_array) {
            var label = Application.database.get_label (id);

            if (label.id != 0) {
                var child = new Widgets.LabelChild (label);
                labels_flowbox.add (child);
            }

            labels_flowbox.show_all ();
        }

        if (is_empty (labels_flowbox) == false) {
            labels_flowbox_revealer.reveal_child = true;
        }

        bool has_reminder = false;
        if (task.has_reminder == 0) {
            has_reminder = false;
            task.reminder_time = new GLib.DateTime.now_local ().to_string ();
        } else {
            has_reminder = true;
        }

        when_button = new Widgets.WhenButton ();
        when_button.set_date (
            new GLib.DateTime.from_iso8601 (task.when_date_utc, new GLib.TimeZone.local ()),
            has_reminder,
            new GLib.DateTime.from_iso8601 (task.reminder_time, new GLib.TimeZone.local ())
        );

        var labels = new Widgets.LabelButton ();

        var move_button = new Widgets.MoveButton ();

        remove_button = new Gtk.Button.from_icon_name ("user-trash-symbolic", Gtk.IconSize.MENU);
        remove_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        remove_button.valign = Gtk.Align.CENTER;

        move_button.on_selected_project.connect ((is_inbox, project) => {
            if (is_inbox) {
                task.is_inbox = 1;
                task.project_id = 0;

                project_preview_label.label = _("Inbox");
                project_preview_icon.get_style_context ().add_class ("proyect-%i".printf (task.project_id));

                hide_content ();
            } else {
                task.is_inbox = 0;
                task.project_id = project.id;

                project_preview_label.label = project.name;
                project_preview_icon.get_style_context ().add_class ("proyect-%i".printf (task.project_id));

                hide_content ();
            }

            Application.notification.send_local_notification (
                task.content,
                _("It was moved to <b>%s</b>").printf (project_preview_label.label),
                "document-export",
                3,
                false);

            update_task ();
        });

        var action_box =  new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        action_box.margin_top = 6;
        action_box.margin_end = 3;
        action_box.margin_bottom = 6;
        action_box.margin_start = 28;
        action_box.valign = Gtk.Align.CENTER;
        action_box.pack_start (when_button, false, false, 0);
        action_box.pack_start (labels, false, false, 0);
        action_box.pack_end (remove_button, false, false, 0);
        action_box.pack_end (move_button, false, false, 0);

        var bottom_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        bottom_box.pack_start (note_eventbox);
        bottom_box.pack_start (checklist_grid);
        bottom_box.pack_start (labels_flowbox_revealer);
        bottom_box.pack_start (action_box);

        bottom_box_revealer = new Gtk.Revealer ();
        bottom_box_revealer.add (bottom_box);
        bottom_box_revealer.transition_duration = 300;
        bottom_box_revealer.reveal_child = false;

        main_grid = new Gtk.Grid ();
        main_grid.margin_top = 3;
        main_grid.margin_end = 5;
        main_grid.expand = true;
        main_grid.get_style_context ().add_class ("task");
        main_grid.orientation = Gtk.Orientation.VERTICAL;

        main_grid.add (top_box);
        main_grid.add (bottom_box_revealer);

        var main_overlay = new Gtk.Overlay ();
        main_overlay.add_overlay (close_revealer);
        main_overlay.add (main_grid);

        var main_eventbox = new Gtk.EventBox ();
        main_eventbox.margin_start = 6;
        main_eventbox.margin_bottom = 3;
        main_eventbox.add_events (Gdk.EventMask.ENTER_NOTIFY_MASK | Gdk.EventMask.LEAVE_NOTIFY_MASK);
        main_eventbox.add (main_overlay);

        add (main_eventbox);
        check_task_completed ();
        //build_drag_and_drop ();

        // Signals
        name_entry.focus_in_event.connect (() => {
            name_entry.secondary_icon_name = "edit-clear-symbolic";
            return false;
        });

        name_entry.focus_out_event.connect (() => {
            name_entry.secondary_icon_name = null;
            return false;
        });

        name_eventbox.button_press_event.connect ((event) => {
            check_task_completed ();
            show_content ();
        });

        name_entry.icon_press.connect ((pos, event) => {
			if (pos == Gtk.EntryIconPosition.SECONDARY) {
				name_entry.text = "";
			}
		});

        close_button.clicked.connect (() => {
            close_revealer.reveal_child = false;
            remove_revealer.reveal_child = false;

            check_task_completed ();
            hide_content ();
        });

        note_eventbox.button_press_event.connect ((event) => {
            Timeout.add (200, () => {
                note_view.grab_focus ();
                return false;
            });

            return false;
        });

        checked_button.toggled.connect (() => {
            check_task_completed ();
            update_task ();
        });

        name_eventbox.enter_notify_event.connect ((event) => {
            name_label.get_style_context ().add_class ("text-hover");
            get_style_context ().add_class ("task-hover");

            return false;
        });

        name_eventbox.leave_notify_event.connect ((event) => {
            if (event.detail == Gdk.NotifyType.INFERIOR) {
                return false;
            }

            name_label.get_style_context ().remove_class ("text-hover");
            get_style_context ().remove_class ("task-hover");
            return false;
        });

        remove_button.clicked.connect (() => {
            close_revealer.reveal_child = false;
            remove_revealer.reveal_child = false;

            var message_dialog = new Granite.MessageDialog.with_image_from_icon_name (
                _("Are you sure you want to delete this to-do?"),
                "",
                "dialog-warning",
            Gtk.ButtonsType.CANCEL);

            var remove_button = new Gtk.Button.with_label (_("Delete To-Do"));
            remove_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
            message_dialog.add_action_widget (remove_button, Gtk.ResponseType.ACCEPT);

            message_dialog.show_all ();

            if (message_dialog.run () == Gtk.ResponseType.ACCEPT) {
                if (Application.database.remove_task (task) == Sqlite.DONE) {
                    var task_preview = "";
                    if (task.content.length > 15) {
                        task_preview = task.content.substring (0, 14) + " ...";
                    } else {
                        task_preview = task.content;
                    }

                    Timeout.add (20, () => {
                        this.opacity = this.opacity - 0.1;

                        if (this.opacity <= 0) {
                            destroy ();
                            return false;
                        }

                        return true;
                    });
                }
            }

            message_dialog.destroy ();
        });

        checklist_entry.activate.connect (() => {
            if (checklist_entry.text != "") {
                var row = new Widgets.CheckRow (checklist_entry.text, false);
                checklist.add (row);

                checklist_entry.text = "";
                checklist.show_all ();
            }
        });

        name_entry.key_release_event.connect ((key) => {
            if (key.keyval == 65307) {
                name_label.label = name_entry.text;
                check_task_completed ();
                hide_content ();
            }

            return false;
        });

        name_entry.activate.connect (() => {
            check_task_completed ();
            hide_content ();
        });

        note_view.key_release_event.connect ((key) => {
            if (key.keyval == 65307) {
                check_task_completed ();
                hide_content ();
            }

            return false;
        });

        main_eventbox.enter_notify_event.connect ((event) => {
            if (bottom_box_revealer.reveal_child == true) {
                close_revealer.reveal_child = true;
                remove_revealer.reveal_child = true;
            }

            return false;
        });

        main_eventbox.leave_notify_event.connect ((event) => {
            if (event.detail == Gdk.NotifyType.INFERIOR) {
                return false;
            }

            close_revealer.reveal_child = false;
            remove_revealer.reveal_child = false;

            return false;
        });

        labels.on_selected_label.connect ((label) => {
            if (is_repeted (label.id) == false) {
                var child = new Widgets.LabelChild (label);
                labels_flowbox.add (child);
            }

            labels_flowbox_revealer.reveal_child = !is_empty (labels_flowbox);
            labels_flowbox.show_all ();
        });

        labels_flowbox.remove.connect ((widget) => {
            labels_flowbox_revealer.reveal_child = !is_empty (labels_flowbox);
        });

        note_view.focus_out_event.connect (() => {
            if (note_view.buffer.text == "") {
                note_view_placeholder_label.visible = true;
                note_view_placeholder_label.no_show_all = false;
            }

            return false;
        });

        note_view.focus_in_event.connect (() => {
            note_view_placeholder_label.visible = false;
            note_view_placeholder_label.no_show_all = true;

            return false;
        });
    }

    private bool is_repeted (int id) {
        foreach (Gtk.Widget element in labels_flowbox.get_children ()) {
            var child = element as Widgets.LabelChild;
            if (child.label.id == id) {
                return true;
            }
        }

        return false;
    }

    private bool is_empty (Gtk.FlowBox flowbox) {
        int l = 0;
        foreach (Gtk.Widget element in flowbox.get_children ()) {
            l = l + 1;
        }

        if (l <= 0) {
            return true;
        } else {
            return false;
        }
    }

    private void check_task_completed () {
        if (name_entry.text != "") {
            name_label.label = name_entry.text;
        }

        if (checked_button.active) {
            name_label.opacity = 0.7;
        } else {
            name_label.opacity = 1;
        }
    }

    public void show_content () {
        main_grid.get_style_context ().add_class ("popover");
        main_grid.get_style_context ().add_class ("planner-popover");

        bottom_box_revealer.reveal_child = true;

        main_grid.margin_start = 5;
        top_box.margin_top = 6;
        top_box.margin_start = 12;
        project_box.margin_end = 6;

        name_entry.visible = true;
        name_eventbox.visible = false;
        checklist_preview.visible = false;

        close_revealer.halign = Gtk.Align.START;
        has_tooltip = false;

        name_entry.text = name_label.label;
    }

    public void hide_content () {
        main_grid.get_style_context ().remove_class ("popover");
        main_grid.get_style_context ().remove_class ("planner-popover");

        main_grid.margin_start = 0;
        top_box.margin_top = 0;
        top_box.margin_start = 0;
        project_box.margin_end = 0;

        name_entry.visible = false;
        name_eventbox.visible = true;
        checklist_preview.visible = true;

        bottom_box_revealer.reveal_child = false;
        close_revealer.halign = Gtk.Align.END;

        if (name_entry.text != "") {
            update_task ();
            tooltip_text = name_entry.text;
            has_tooltip = true;
        }
    }

    public void update_task () {
        task.project_id = task.project_id;
        task.content = name_entry.text;
        task.note = note_view.buffer.text;

        if (checked_button.active) {
            task.checked = 1;
        } else {
            task.checked = 0;
        }

        if (when_button.has_duedate) {
            task.when_date_utc = when_button.when_datetime.to_string ();

            if (Granite.DateTime.is_same_day (new GLib.DateTime.now_local (), when_button.when_datetime)) {
                when_preview_label.label = _("Today");
            } else if (Application.utils.is_tomorrow (when_button.when_datetime)) {
                when_preview_label.label = _("Tomorrow");
            } else {
                int day = when_button.when_datetime.get_day_of_month ();
                string month = Application.utils.get_month_name (when_button.when_datetime.get_month ());
                when_preview_label.label = "%i %s".printf (day, month);
            }

            when_preview_box.visible = true;
            when_preview_box.no_show_all = false;
        } else {
            task.when_date_utc = "";

            when_preview_box.visible = false;
            when_preview_box.no_show_all = true;
        }

        if (when_button.reminder_datetime.to_string () != task.reminder_time) {
            task.was_notified = 0;

            if (when_button.has_reminder) {
                // Send Notification
                Application.notification.send_local_notification (
                    task.content,
                    _("You'll be notified %s".printf (Granite.DateTime.get_relative_datetime (when_button.reminder_datetime))),
                    "preferences-system-time",
                    3,
                    false);
            }
        }

        if (when_button.has_reminder) {
            task.has_reminder = 1;
            task.reminder_time = when_button.reminder_datetime.to_string ();

            string hour = when_button.reminder_datetime.get_hour ().to_string ();
            string minute = when_button.reminder_datetime.get_minute ().to_string ();

            if (minute.length <= 1) {
                minute = "0" + minute;
            }

            if (hour.length <= 1) {
                hour = "0" + hour;
            }

            reminder_preview_label.label = "%s:%s".printf (hour, minute);

            reminder_preview_box.visible = true;
            reminder_preview_box.no_show_all = false;
        } else {
            task.has_reminder = 0;
            task.reminder_time = "";

            reminder_preview_box.visible = false;
            reminder_preview_box.no_show_all = true;
        }

        show_all ();
        Application.database.update_task_signal (task);

        Thread<void*> thread = new Thread<void*>.try("Update Task Thread", () => {
            task.labels = "";
            foreach (Gtk.Widget element in labels_flowbox.get_children ()) {
                var child = element as Widgets.LabelChild;
                task.labels = task.labels + child.label.id.to_string () + ";";
            }

            task.checklist = "";
                foreach (Gtk.Widget element in checklist.get_children ()) {
                var row = element as Widgets.CheckRow;
                task.checklist = task.checklist + row.get_check ();
            }


            if (Application.database.update_task (task) == Sqlite.DONE) {
                on_signal_update ();
            }

            return null;
    	});
    }

    /*
    private void build_drag_and_drop () {
        Gtk.drag_source_set (this, Gdk.ModifierType.BUTTON1_MASK, targetEntriesProjectRow, Gdk.DragAction.MOVE);

        drag_begin.connect (on_drag_begin);
    }

    private void on_drag_begin (Gtk.Widget widget, Gdk.DragContext context) {
        var row = (widget as Widgets.TaskRow);

        Gtk.Allocation alloc;
		row.get_allocation (out alloc);

        var surface = new Cairo.ImageSurface (Cairo.Format.ARGB32, alloc.width, alloc.height);
        var cr = new Cairo.Context (surface);
		cr.set_source_rgba (0, 0, 0, 0.3);
		cr.set_line_width (1);

        cr.move_to (0, 0);
		cr.line_to (alloc.width, 0);
		cr.line_to (alloc.width, alloc.height);
		cr.line_to (0, alloc.height);
		cr.line_to (0, 0);
		cr.stroke ();

        cr.set_source_rgba (255, 255, 255, 0.5);
		cr.rectangle (0, 0, alloc.width, alloc.height);
		cr.fill ();

        row.main_grid.draw (cr);

		Gtk.drag_set_icon_surface (context, surface);
    }
    */
 }
