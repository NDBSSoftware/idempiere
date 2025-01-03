/******************************************************************************
 * Product: Posterita Ajax UI 												  *
 * Copyright (C) 2007 Posterita Ltd.  All Rights Reserved.                    *
 * This program is free software; you can redistribute it and/or modify it    *
 * under the terms version 2 of the GNU General Public License as published   *
 * by the Free Software Foundation. This program is distributed in the hope   *
 * that it will be useful, but WITHOUT ANY WARRANTY; without even the implied *
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.           *
 * See the GNU General Public License for more details.                       *
 * You should have received a copy of the GNU General Public License along    *
 * with this program; if not, write to the Free Software Foundation, Inc.,    *
 * 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA.                     *
 * For the text or an alternative of this public license, you may reach us    *
 * Posterita Ltd., 3, Draper Avenue, Quatre Bornes, Mauritius                 *
 * or via info@posterita.org or http://www.posterita.org/                     *
 *****************************************************************************/

package org.adempiere.webui.component;

import org.adempiere.webui.ISupportMask;
import org.adempiere.webui.ShowMaskWrapper;
import org.adempiere.webui.event.DialogEvents;
import org.zkoss.zk.ui.Component;
import org.zkoss.zk.ui.Executions;
import org.zkoss.zk.ui.Page;
import org.zkoss.zk.ui.event.Event;
import org.zkoss.zk.ui.event.Events;

/**
 * Extend {@link org.zkoss.zul.Window}
 * @author  <a href="mailto:agramdass@gmail.com">Ashley G Ramdass</a>
 * @date    Feb 25, 2007
 */
public class Window extends org.zkoss.zul.Window implements ISupportMask
{
	/**
	 * generated serial id
	 */
	private static final long serialVersionUID = 3187379158546966625L;

	protected ShowMaskWrapper showMaskWrapper = new ShowMaskWrapper(this);
	/** Show as modal window */
    public static final String MODE_MODAL = "modal";
    /** Show as popup window */
    public static final String MODE_POPUP =  "popup";
    /** Show as floating/overlapped window */
    public static final String MODE_OVERLAPPED =  "overlapped";
    /** Show as desktop tab */
    public static final String MODE_EMBEDDED =  "embedded";
    /** Show as overlapped window with background mask */
    public static final String MODE_HIGHLIGHTED = "highlighted";
    /** Window attribute to store display mode (modal, popup, etc) */
    public static final String MODE_KEY = "mode";
    
    /** Window attribute to store desktop tab insert position for embedded mode */
    public static final String INSERT_POSITION_KEY = "insertPosition";
    /** Append to the end of tabs of desktop */
    public static final String INSERT_END = "insertEnd";
    /** Insert next to the active tab of desktop */
    public static final String INSERT_NEXT = "insertNext";
    /** Replace current desktop tab content */
    public static final String REPLACE = "replace";
    
    /** Window attribute to set the decorate info */
    public static final String DECORATE_INFO = "decorateInfo";

    /** if true, fire ON_WINDOW_CLOSE event when detached from page */
    private boolean fireWindowCloseEventOnDetach = true;
    
    /**
     * Default constructor
     */
    public Window()
    {
        super();
    }
    
    /**
     * Alias for detach, to ease porting of swing form
     */
    public void dispose()
    {
    	detach();
    }

	/* (non-Javadoc)
	 * @see org.zkoss.zul.Window#onPageDetached(org.zkoss.zk.ui.Page)
	 */
	@Override
	public void onPageDetached(Page page) {
		super.onPageDetached(page);
		if (Executions.getCurrent() != null && Executions.getCurrent().getDesktop() != null &&
				Executions.getCurrent().getDesktop().getExecution() != null) {
			if (fireWindowCloseEventOnDetach)
				Events.sendEvent(this, new Event(DialogEvents.ON_WINDOW_CLOSE, this, null));
		}
	}
	
	/**
	 * Get the window mode attribute
	 * @return Window.Mode
	 */
	public Mode getModeAttribute() {
		Object modeValue = getAttribute(Window.MODE_KEY);
		if (modeValue instanceof Mode) {
			return (Mode) modeValue;
		}
		
		final String mode = modeValue != null ? modeValue.toString() : Window.MODE_HIGHLIGHTED;
		if (Window.MODE_EMBEDDED.equals(mode)) {
			return Mode.EMBEDDED;
		} else if (Window.MODE_HIGHLIGHTED.equals(mode)) {
			return Mode.HIGHLIGHTED;
		} else if (Window.MODE_MODAL.equals(mode)) {
			return Mode.MODAL;
		} else if (Window.MODE_OVERLAPPED.equals(mode)) {
			return Mode.OVERLAPPED;
		} else if (Window.MODE_POPUP.equals(mode)) {
			return Mode.POPUP;
		} else {
			return Mode.HIGHLIGHTED;
		}
	}
	
	/**
	 * {@inheritDoc}
	 */
	@Override
	public void showMask() {
		showMaskWrapper.showMask();

	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	public void hideMask() {
		showMaskWrapper.hideMask();
		
	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	public Mask getMaskObj() {
		return showMaskWrapper.getMaskObj();
	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	public Component getMaskComponent() {		
		return showMaskWrapper.getMaskComponent();
	}

	/**
	 * @return true if {@link DialogEvents#ON_WINDOW_CLOSE} event is fire when window is detach from page
	 */
	public boolean isFireWindowCloseEventOnDetach() {
		return fireWindowCloseEventOnDetach;
	}

	/**
	 * @param fireWindowCloseEventOnDetach true to fire {@link DialogEvents#ON_WINDOW_CLOSE} event when window is detach from page (default is true)
	 */
	public void setFireWindowCloseEventOnDetach(boolean fireWindowCloseEventOnDetach) {
		this.fireWindowCloseEventOnDetach = fireWindowCloseEventOnDetach;
	}
}
