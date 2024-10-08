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

import org.adempiere.webui.apps.AEnv;
import org.compiere.util.DisplayType;
import org.compiere.util.Env;

/**
 * Extend {@link org.zkoss.zul.Datebox}
 * @author  <a href="mailto:agramdass@gmail.com">Ashley G Ramdass</a>
 * @date    Feb 25, 2007
 */
public class Datebox extends org.zkoss.zul.Datebox
{
	/**
	 * generated serial id
	 */
	private static final long serialVersionUID = -5890574778856946570L;

	/**
	 * Default constructor.
	 * Set format to pattern from {@link DisplayType#getDateFormat(org.compiere.util.Language)}.
	 */
	public Datebox() {
		super();
		setFormat(DisplayType.getDateFormat(AEnv.getLanguage(Env.getCtx())).toPattern());
	}

	/**
	 * @param enabled
	 */
	public void setEnabled(boolean enabled)
    {
        this.setReadonly(!enabled);
        this.setDisabled(!enabled);
        this.setButtonVisible(enabled);
    }
    
	/**
	 * @return true if enable, false otherwise
	 */
    public boolean isEnabled()
    {
    	return !isReadonly();
    }
}
